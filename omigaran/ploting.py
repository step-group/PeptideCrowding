# THIS FILE IS TO PLOT THE ENERGY FILES OF THE DIFFERENT STEPS
#%%
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import os
import argparse


def _parse_xvg_header(energy_file):
    """Read only the @/# header lines of a .xvg file (title, axis labels, legends)."""
    legend, xlabel, ylabel, title_ = [], '', '', ''
    with open(energy_file) as f:
        for line in f:
            if line.startswith('@'):
                if "legend" in line and '"' in line:
                    legend.append(line.split('"')[1])
                elif "xaxis" in line:
                    xlabel = line.split('"')[1]
                elif "yaxis" in line:
                    ylabel = line.split('"')[1]
                elif 'title' in line and 'sub' not in line:
                    title_ = line.split('"')[1]
            elif not line.startswith('#'):
                break
    return legend, xlabel, ylabel, title_


def _add_series(ax, x, y, label, rolling_average):
    ax.plot(x, y, label=label)
    if rolling_average:
        window_size = 100
        y_smooth = pd.Series(y).rolling(window=window_size, min_periods=1).mean()
        final = y_smooth.iloc[-1]
        ax.plot(x, y_smooth, label=f"{label} rolling avg (window={window_size})")
        ax.axhline(y=final, linestyle='--', label=f"{label} final: {final:.2f}")


def plot_energy_file(energy_file, title, folder, rolling_average=False, log_scale=False,
                     cols_to_plot=None):
    """Plot one or more data columns from a GROMACS .xvg file.

    cols_to_plot: list of 1-indexed column numbers as they appear in the .xvg
    (column 0 is always time/x-axis and is never plotted directly). If None,
    plots column 1 (the only y-column expected in a single-series file).
    """
    legend, xlabel, ylabel, title_ = _parse_xvg_header(energy_file)

    if len(legend) > 1 and cols_to_plot is None:
        raise ValueError(".xvg contains multiple columns, but cols_to_plot is not specified. "
                        "Please specify which columns to plot.")

    data = np.atleast_2d(np.loadtxt(energy_file, skiprows=1, comments=["#", "@"], unpack=True))
    x = data[0]

    fig, ax = plt.subplots(figsize=(10, 6))

    if cols_to_plot is None:
        y = data[1]
        label = legend[0] if legend else title_
        _add_series(ax, x, y, label, rolling_average)
    else:
        for col in cols_to_plot:
            if col == 0 or col >= data.shape[0]:
                raise ValueError(f"column {col} is out of range for this file "
                                f"(valid data columns: 1..{data.shape[0] - 1})")
            y = data[col]
            # file column 0 is time/x-axis, so legend index is offset by -1
            label = legend[col - 1] if legend and (col - 1) < len(legend) else f"col {col}"
            _add_series(ax, x, y, label, rolling_average)

    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    if log_scale:
        ax.set_yscale('symlog')
    ax.legend()
    ax.set_title(title)

    os.makedirs(folder, exist_ok=True)
    fig.savefig(os.path.join(folder, f"{title}.png"), dpi=300)
    plt.close(fig)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Plot energy/analysis files from GROMACS (.xvg).")
    parser.add_argument("--file", type=str, required=True, help=".xvg file to plot")
    parser.add_argument("--title", type=str, required=True, help="Title for the plot (also used as the output filename)")
    parser.add_argument("--folder", type=str, required=True, help="Output folder for the plot")
    parser.add_argument("--rolling_average", action="store_true", help="Overlay a rolling average on each series")
    parser.add_argument("--log_scale", action="store_true", help="Use symlog scale for the y-axis")
    parser.add_argument("--cols", type=int, nargs='+', default=None,
                        help="1-indexed data column(s) to plot (column 0 is time/x-axis and is never plotted). "
                             "If omitted, plots column 1.")
    args = parser.parse_args()

    plot_energy_file(args.file, args.title, args.folder,
                     rolling_average=args.rolling_average,
                     log_scale=args.log_scale,
                     cols_to_plot=args.cols)