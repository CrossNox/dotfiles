#!/usr/bin/env python3

"""This script converts cava's data output into fancy little bars."""

import argparse
import configparser
import os
import pathlib
import struct
import subprocess
import sys
import tempfile
import time

BAR_FACTOR = 100 / 7
BAR_CHARACTERS = {
    000: "▁",  # Zero output
    BAR_FACTOR * 1: "▁",
    BAR_FACTOR * 2: "▂",
    BAR_FACTOR * 3: "▃",
    BAR_FACTOR * 4: "▄",
    BAR_FACTOR * 5: "▅",
    BAR_FACTOR * 6: "▆",
    BAR_FACTOR * 7: "▇",
    100: "█",  # Highest output
}
PIPE_IN = pathlib.Path(tempfile.gettempdir()) / "cava_polybar_input.fifo"


def output(string, file, output_delay):
    """
    Print/Write the given value either to STDOUT ot the specified output pipe

    Args:
        string ([string]): String to print
        file ([file]): [description]
    """

    print(string, end="", file=file, flush=True)

    time.sleep(output_delay)


def value_to_character(value):
    """
    Returns the respective character for a value. Returns 'highest' character if no match is found

    Args:
        value ([int]): Value that should be mapped to a character

    Returns:
        [char]: Respective character for the given value
    """

    for bar_threshold, bar_char in BAR_CHARACTERS.items():
        if value < bar_threshold:
            return bar_char
    return BAR_CHARACTERS[100]


def run(
    separator,
    hide_when_empty,
    output_delay,
    empty_output_threshold,
    pipe_out,
    config_file,
    bars,
    bit_format,
):
    """Prepare variables and run the conversion process."""

    create_cava_config(bars, bit_format, config_file)

    if pipe_out is not None:
        if pathlib.Path(pipe_out).exists():
            os.remove(pipe_out)
        os.mkfifo(pipe_out)

    # Create cava subprocess
    with open(  # pylint: disable=unspecified-encoding
        os.devnull, "w"
    ) as fnull, subprocess.Popen(
        ["cava", "-p", config_file], stdout=fnull, stderr=subprocess.STDOUT
    ), open(  # pylint: disable=unspecified-encoding
        pipe_out, "w"
    ) if pipe_out else sys.stdout as output_pipe:
        exit_code = 0
        with open(PIPE_IN, "rb") as input_pipe:
            # Run the conversion process
            try:
                convert(
                    input_pipe,
                    bit_format,
                    empty_output_threshold,
                    bars,
                    hide_when_empty,
                    separator,
                    output_delay,
                    output_pipe,
                )
            except KeyboardInterrupt:
                exit_code = 1

        # Close output pipe if needed
        if pipe_out:
            output_pipe.close()
            os.remove(pipe_out)

        sys.exit(exit_code)


def convert(
    input_pipe,
    bit_format,
    empty_output_threshold,
    bars_number,
    hide_when_empty,
    separator,
    output_delay,
    output_pipe,
):
    """Converts values taken from the input pipe to printable characters.
    The result is either printed to STDOUT or written to the output pipe
    """
    bytetype, bytesize, bytenorm = (
        ("H", 2, 65535) if bit_format == "16bit" else ("B", 1, 255)
    )

    # Initialize variables
    chunk = bytesize * bars_number
    fmt = bytetype * bars_number

    empty_outputs = 0

    # Convert
    while True:
        raw_data = input_pipe.read(chunk)
        if len(raw_data) < chunk:
            break

        tstring = ""
        empty_output = True

        for i in struct.unpack(fmt, raw_data):
            value = int(i / bytenorm * 100)

            if len(tstring) > 0:
                tstring += separator
            tstring += value_to_character(value)

            if value != 0:
                empty_output = False

        if empty_output and hide_when_empty:
            empty_outputs += 1
            if empty_outputs > empty_output_threshold:
                output(f"        {os.linesep}", output_pipe, output_delay)
        else:
            empty_outputs = 0
            output(f"{tstring}{os.linesep}", output_pipe, output_delay)


def create_cava_config(bars_number, bit_format, config_file):
    """ Create the temporary configuration file used by the cava subprocess"""

    config = configparser.ConfigParser()

    config.add_section("general")
    config.set("general", "bars", str(bars_number))
    config.set("general", "overshoot", str(0))

    config.add_section("output")
    config.set("output", "method", "raw")
    config.set("output", "channels", "mono")
    config.set("output", "mono_option", "average")
    config.set("output", "raw_target", PIPE_IN.resolve().as_posix())
    config.set("output", "bit_format", bit_format)

    config.add_section("smoothing")
    config.set("smoothing", "integral", "0")

    with open(config_file, "w") as configfile:  # pylint: disable=unspecified-encoding
        config.write(configfile)


def print_test_data():
    """Prints test data to stdout. Useful for checking resolution and customisation configuration."""

    newline = "\n"
    bar_chars = [f"{k:06.2f}: {v}" for k, v in BAR_CHARACTERS.items()]

    print(
        f"""
Bar Characters:
{newline.join(bar_chars)}

Value Test:
"""
    )
    for i in range(101):
        print(f"{i:03d}: {value_to_character(i)}")


def main():
    """Main entrypoint."""
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument("--test", action="store_true")
    parser.add_argument(
        "--separator", "-s", default=" ", help="Separator Character between bars"
    )
    parser.add_argument(
        "--hide-when-empty",
        "-e",
        action="store_false",
        help="Display no output if all bars are at minimum level (no sound output)",
    )
    parser.add_argument(
        "--output-delay",
        "-d",
        type=float,
        help="How long this script should wait before printing another value",
        default=0.0005,
    )
    parser.add_argument(
        "--empty-output-threshold",
        "-t",
        type=int,
        default=5,
        help="How many times cava can report 'no sound' (all values are 0) before the script detects it",
    )
    parser.add_argument(
        "--pipe-out",
        "-o",
        type=pathlib.Path,
        default=None,
        help="Path to the named pipe the script should write to. If not passed, FIFO output is disabledt and the script prints to STDOUT.",
    )
    parser.add_argument(
        "--config-file",
        "-c",
        type=pathlib.Path,
        default=pathlib.Path("/tmp/cava_polybar.config"),
        help="Path of the temporary cava configuration used to run the cava subprocess.",
    )
    parser.add_argument(
        "--bars", "-b", type=int, default=8, help="Number of bars in cava"
    )
    parser.add_argument(
        "--bit-format",
        default="8bit",
        choices=["8bit", "16bit"],
        help="Output bit format for cava",
    )

    args = parser.parse_args()

    if args.test:
        print_test_data()
        sys.exit(0)
    run(
        args.separator,
        args.hide_when_empty,
        args.output_delay,
        args.empty_output_threshold,
        args.pipe_out,
        args.config_file,
        args.bars,
        args.bit_format,
    )


if __name__ == "__main__":
    main()
