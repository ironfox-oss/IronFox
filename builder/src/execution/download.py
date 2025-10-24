import logging
import time
import requests

from pathlib import Path
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
from rich.progress import Progress

from .definition import BuildDefinition, TaskDefinition
from common.utils import sha256sum, format_bytes
from common.versions import Versions as Versions

CHUNK_SIZE = 16 * 1024  # 16KB
TIMEOUT_SECONDS = 30
MAX_RETRIES = 3
BACKOFF_FACTOR = 0.3


class DownloadTask(TaskDefinition):
    def __init__(
        self,
        name: str,
        id: int,
        build_def: BuildDefinition,
        url: str,
        destination: Path,
        sha256: str,
    ):
        super().__init__(name, id, build_def)
        self.url = url
        self.destination = destination
        self.sha256 = sha256

    def execute(self, params):
        return download_if_needed(
            url=self.url,
            destination=self.destination,
            sha256=self.sha256,
            progress=params.progress,
            logger=self.logger,
        )


def download_if_needed(
    url: str,
    destination: Path,
    sha256: str,
    progress: Progress,
    logger: logging.Logger,
):
    if destination.exists():
        try:
            existing_hash = sha256sum(destination)
            if existing_hash == sha256:
                logger.info(
                    f"File {destination} already exists and is verified. Skipping download."
                )
                return
            else:
                logger.warning(
                    f"File {destination} exists but has incorrect checksum. Re-downloading."
                )
                logger.warning(f"Expected: {sha256}, Found: {existing_hash}")
        except Exception as e:
            logger.warning(
                f"Could not verify existing file {destination}: {e}. Re-downloading."
            )

    # Ensure parent directory exists
    try:
        destination.parent.mkdir(parents=True, exist_ok=True)
    except OSError as e:
        logger.error(f"Failed to create directory {destination.parent}: {e}")
        raise

    download_with_progress(
        url,
        destination,
        sha256,
        progress,
        logger,
    )


def download_with_progress(
    url: str,
    destination: Path,
    sha256: str,
    progress: Progress,
    logger: logging.Logger,
):
    logger.info(f"Downloading {url} to {destination}")

    session = requests.Session()
    retry_strategy = Retry(
        total=MAX_RETRIES,
        status_forcelist=[429, 500, 502, 503, 504],
        allowed_methods=["HEAD", "GET", "OPTIONS"],
        backoff_factor=BACKOFF_FACTOR,
    )

    adapter = HTTPAdapter(max_retries=retry_strategy)
    session.mount("http://", adapter)
    session.mount("https://", adapter)

    headers = {"User-Agent": f"IronFox/{Versions.IRONFOX_VERSION} (Download Client)"}

    task_id = None
    temp_file = None

    try:
        logger.debug(f"Making HEAD request to {url} to get file size")
        try:
            head_response = session.head(url, headers=headers, timeout=TIMEOUT_SECONDS)
            head_response.raise_for_status()
            total_size = int(head_response.headers.get("content-length", 0))
        except (requests.RequestException, ValueError, KeyError) as e:
            logger.debug(
                f"HEAD request failed or no content-length: {e}. Proceeding with GET request."
            )
            total_size = 0

        logger.debug(f"Starting GET request to {url}")
        response = session.get(
            url, headers=headers, stream=True, timeout=TIMEOUT_SECONDS
        )
        response.raise_for_status()

        if total_size == 0:
            total_size = int(response.headers.get("content-length", 0))

        if total_size > 0:
            logger.info(f"Total size to download: {format_bytes(total_size)}")
        else:
            logger.info("Download size unknown")

        task_id = progress.add_task(
            f"Downloading {destination.name}",
            total=total_size if total_size > 0 else None,
        )

        temp_file = destination.with_suffix(destination.suffix + ".tmp")

        with open(temp_file, "wb") as f:
            total_downloaded = 0
            last_log_time = time.time()
            last_log_bytes = 0

            try:
                for chunk in response.iter_content(chunk_size=CHUNK_SIZE):
                    if chunk:  # Filter out keep-alive chunks
                        bytes_written = f.write(chunk)
                        total_downloaded += bytes_written

                        if task_id is not None:
                            progress.update(task_id, advance=bytes_written)

                        current_time = time.time()
                        if current_time - last_log_time >= 5.0:  # Log every 5 seconds
                            bytes_since_last_log = total_downloaded - last_log_bytes
                            speed = bytes_since_last_log / (
                                current_time - last_log_time
                            )

                            if total_size > 0:
                                percent = (total_downloaded / total_size) * 100
                                logger.debug(
                                    f"Downloaded {format_bytes(total_downloaded)}"
                                    f"/{format_bytes(total_size)} ({percent:.1f}%) "
                                    f"at {format_bytes(speed)}/s"
                                )
                            else:
                                logger.debug(
                                    f"Downloaded {format_bytes(total_downloaded)} "
                                    f"at {format_bytes(speed)}/s"
                                )

                            last_log_time = current_time
                            last_log_bytes = total_downloaded

            except Exception as e:
                logger.error(f"Error during download: {e}")
                if temp_file.exists():
                    try:
                        temp_file.unlink()
                    except OSError as cleanup_error:
                        logger.warning(
                            f"Failed to clean up partial download: {cleanup_error}"
                        )
                raise

        # Verify download completed successfully
        if total_size > 0 and total_downloaded != total_size:
            logger.error(
                f"Download incomplete: got {total_downloaded} bytes, expected {total_size}"
            )
            temp_file.unlink()
            raise requests.RequestException(
                f"Incomplete download: {total_downloaded}/{total_size} bytes"
            )

        logger.info(f"Download completed: {format_bytes(total_downloaded)} total")

        # Verify checksum
        logger.debug("Verifying file checksum...")
        actual_hash = sha256sum(temp_file)
        if actual_hash != sha256:
            logger.error(f"Checksum verification failed!")
            logger.error(f"Expected: {sha256}")
            logger.error(f"Actual:   {actual_hash}")
            temp_file.unlink()
            raise ValueError(
                f"Checksum mismatch for {destination}. Expected {sha256}, got {actual_hash}"
            )

        # Move temp file to final destination
        try:
            temp_file.rename(destination)
        except OSError as e:
            logger.error(f"Failed to move temporary file to final destination: {e}")
            temp_file.unlink()
            raise

        logger.info(f"Download completed and verified: {destination}")

    except requests.exceptions.Timeout:
        logger.error(f"Download timed out after {TIMEOUT_SECONDS} seconds")
        raise

    except requests.exceptions.ConnectionError as e:
        logger.error(f"Connection error during download: {e}")
        raise

    except requests.exceptions.HTTPError as e:
        logger.error(f"HTTP error during download: {e}")
        logger.error(
            f"Response status: {e.response.status_code if e.response else 'Unknown'}"
        )
        raise

    except requests.exceptions.RequestException as e:
        logger.error(f"Request failed: {e}")
        raise

    except OSError as e:
        logger.error(f"File system error: {e}")
        raise

    except Exception as e:
        logger.error(f"Unexpected error during download: {e}")
        raise

    finally:
        # Clean up
        if task_id is not None and progress:
            try:
                progress.remove_task(task_id)
            except Exception as e:
                logger.debug(f"Failed to remove progress task: {e}")

        if temp_file and temp_file.exists():
            try:
                temp_file.unlink()
                logger.debug("Cleaned up temporary download file")
            except OSError as e:
                logger.warning(f"Failed to clean up temporary file {temp_file}: {e}")

        try:
            session.close()
        except Exception as e:
            logger.debug(f"Error closing session: {e}")
