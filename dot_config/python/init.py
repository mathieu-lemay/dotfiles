import atexit
import os
import readline
from pathlib import Path


def _get_hist_file() -> Path:
    if "PYTHONHISTFILE" in os.environ:
        history = Path(os.environ["PYTHONHISTFILE"])
    elif "XDG_STATE_HOME" in os.environ:
        history = Path(os.environ["XDG_STATE_HOME"]) / "python" / "history"
    else:
        history = (Path("~") / "python")

    history = history.absolute().expanduser()

    if not history.exists():
        history.parent.mkdir(parents=True, exist_ok=True)
        # Write a dummy history to avoid an operation not permitted error
        history.write_text("_HiStOrY_V2_\nexit()\n")

    return history

def _setup_history() -> None:
    hist_file = _get_hist_file()

    try:
        readline.read_history_file(hist_file)
        # default history len is -1 (infinite), which may grow unruly
        readline.set_history_length(10000)
    except IOError:
        pass

    atexit.register(readline.write_history_file, hist_file)


_setup_history()
