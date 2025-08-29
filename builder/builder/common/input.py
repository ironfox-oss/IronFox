"""Utilities for user input"""


def ask_confirmation(prompt="Are you sure? (y/n): "):
    """
    Prompt the user for a yes/no confirmation and return `True` or `False` based
    on the response.

    Accepted as YES: 'y', 'Y', 'yes', 'Yes', 'YES'
    Accepted as NO: 'n', 'N', 'no', 'No', 'NO'
    """

    while True:
        response = input(prompt).strip().lower()
        if response in ["y", "yes"]:
            return True
        elif response in ["n", "no"]:
            return False
        else:
            print("Invalid repsonse. Valid inputs are YES/yes/Yes/Y/y/NO/no/No/N/n")
