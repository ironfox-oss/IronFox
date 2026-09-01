package org.mozilla.fenix.onboarding

import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import mozilla.components.support.base.feature.LifecycleAwareFeature
import org.mozilla.fenix.onboarding.view.OnboardingPageUiData
import kotlin.coroutines.CoroutineContext

/**
 * Handles adding and removing onboarding pages if certain conditions are met.
 *
 * @param pagesToDisplay the mutable list of onboarding pages we display
 * @param mainContext the coroutine context for UI
 * @param ioContext the coroutine context for IO
 * @param lifecycleOwner the lifecycle owner
 */
class IFOnboardingPageAdditionSupport(
  private val pagesToDisplay: MutableList<OnboardingPageUiData>,
  private val mainContext: CoroutineContext = Dispatchers.Main,
  private val ioContext: CoroutineContext = Dispatchers.IO,
  private val lifecycleOwner: LifecycleOwner,
) : LifecycleAwareFeature {

  var currentPageIndex: Int = 0

  private var job: Job? = null

  override fun start() {
    job = lifecycleOwner.lifecycleScope.launch(ioContext) {
      // Remove unwanted onboarding pages
      pagesToDisplay.removeIfPageNotReached(currentPageIndex)
    }
  }

  override fun stop() {
    job?.cancel()
  }
}

// Remove unwanted onboarding pages
internal fun MutableList<OnboardingPageUiData>.removeIfPageNotReached(index: Int) {
  val searchWidgetIndex = indexOfFirst { it.type == OnboardingPageUiData.Type.ADD_SEARCH_WIDGET }
  val syncIndex = indexOfFirst { it.type == OnboardingPageUiData.Type.SYNC_SIGN_IN }

  if (index < syncIndex) {
    removeAt(syncIndex)
  }

  if (index < searchWidgetIndex) {
    removeAt(searchWidgetIndex)
  }
}
