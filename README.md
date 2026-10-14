# Solving Sudoku in 3 Lines with Clingo

This repo goes with the [CodeSlate video](https://youtu.be/UBFWS6_Hrmc) on solving Sudoku with **Answer Set Programming (ASP)** and the **Clingo** solver. It has the two Sudoku programs from the video and a folder of puzzles to run them on.

The guide covers:

1. [What's in this repo](#whats-in-this-repo)
2. [What the puzzle files look like](#what-the-puzzle-files-look-like)
3. [Installing Clingo](#installing-clingo) on [Windows](#windows), [macOS](#macos), or [Linux](#linux)
4. [Running the solver](#running-the-solver)
5. [Reading the output](#reading-the-output)
6. [Making your own puzzle](#making-your-own-puzzle)
7. [Troubleshooting](#troubleshooting)

If you'd like to try it before installing anything, see [No install: run it in your browser](#no-install-run-it-in-your-browser).

---

## What's in this repo

```
.
├── sudoku_simple.lp          # the 4-line solver
├── sudoku_simple_3liner.lp   # the 3-line solver
└── boards/                   # puzzles, one per file
    ├── easy_1.lp
    ├── featured.lp
    └── ...
```

### The 4-line solver: `sudoku_simple.lp`

```prolog
1 { in(R,C,N) : N = 1..9 } 1 :- R = 1..9, C = 1..9.

:- in(R,C1,N), in(R,C2,N), C1 != C2.
:- in(R1,C,N), in(R2,C,N), R1 != R2.
:- in(R1,C1,N), in(R2,C2,N), (R1,C1) != (R2,C2), (R1-1)/3 == (R2-1)/3, (C1-1)/3 == (C2-1)/3.
```

- **Line 1:** every cell `(R,C)` gets exactly one number `N` from 1 to 9.
- **Line 2:** no number appears twice in the same row.
- **Line 3:** no number appears twice in the same column.
- **Line 4:** no number appears twice in the same 3×3 box. Integer division `(R-1)/3` gives the box index 0, 1, or 2.

### The 3-line solver: `sudoku_simple_3liner.lp`

```prolog
1 { in(R,C,N) : N = 1..9 } 1 :- R = 1..9, C = 1..9.
:- in(R1,C1,N), in(R2,C2,N), (R1,C1) != (R2,C2), grp(R1,C1,G), grp(R2,C2,G).
grp(R,C, (row,R; col,C; box,(R-1)/3,(C-1)/3)) :- R = 1..9, C = 1..9.
```

- **Line 1:** the same as before. Every cell gets exactly one number.
- **Line 3:** puts every cell in three groups: its row, its column, and its box.
- **Line 2:** two different cells in the same group can't hold the same number. This one rule replaces the three separate constraints in the 4-line version.

Neither file contains a puzzle. You give Clingo a solver file **and** a puzzle file, and Clingo combines them.

---

## What the puzzle files look like

Each file in `boards/` lists the numbers already filled in. Each given is one **fact** (a literal that is simply true):

```prolog
in(Row, Col, Num).
```

- `Row` runs from 1 (top) to 9 (bottom).
- `Col` runs from 1 (left) to 9 (right).
- `Num` is the digit in that cell.
- Every fact ends with a period (`.`).
- Empty cells are left out.

Here is `boards/featured.lp` in full:

```prolog
% featured: in(Row, Col, Num) for each given number
#show in/3.

in(1,1,2). in(1,2,1). in(1,4,9). in(1,5,5). in(1,9,4).
in(2,2,9). in(2,5,6). in(2,8,3). in(2,9,7).
in(3,4,7).
in(4,7,3). in(4,9,8).
in(5,1,9). in(5,2,2). in(5,8,1). in(5,9,5).
in(6,1,8). in(6,3,5).
in(7,6,2).
in(8,1,6). in(8,2,8). in(8,5,1). in(8,8,4).
in(9,1,1). in(9,5,4). in(9,6,7). in(9,8,9). in(9,9,6).
```

That is this puzzle (`.` marks an empty cell):

```
2 1 . | 9 5 . | . . 4
. 9 . | . 6 . | . 3 7
. . . | 7 . . | . . .
------+-------+------
. . . | . . . | 3 . 8
9 2 . | . . . | . 1 5
8 . 5 | . . . | . . .
------+-------+------
. . . | . . 2 | . . .
6 8 . | . 1 . | . 4 .
1 . . | . 4 7 | . 9 6
```

For example, `in(1,1,2).` means "row 1, column 1 holds a 2", and `in(9,9,6).` means "the bottom-right cell holds a 6".

The other two lines in the file:

- `% ...` is a **comment**. Clingo ignores everything after a `%`.
- `#show in/3.` tells Clingo to print only the `in(...)` atoms (the 3 means three arguments). Without it, Clingo also prints the helper atoms, such as the `grp(...)` atoms in the 3-line solver.

### Why the givens work

Line 1 of each solver says every cell holds **exactly one** number. When the puzzle file says `in(1,1,2)` is true, cell (1,1) already has its one number, so Clingo can't put anything else there. The givens fix those cells, and Clingo fills in the rest.

---

## Installing Clingo

Clingo is free and open source. It is developed by the [Potassco group](https://potassco.org/) at the University of Potsdam. Each operating system has more than one way to install it. Pick **one** option for yours.

> **Pip vs. a native install:** installing with Python's `pip` gives you the Clingo solver, but it does **not** add a `clingo` command. You run it as `python -m clingo` instead. The other methods (conda, Homebrew, apt) give you a real `clingo` command. Both behave the same.

### Windows

#### Option A: pip (recommended if you have Python, or don't mind installing it)

1. **Install Python** if you don't have it. Download it from [python.org/downloads](https://www.python.org/downloads/) and run the installer.
   - On the first screen of the installer, **tick "Add python.exe to PATH"** before you click *Install Now*.
2. **Open a terminal.** Press the Windows key, type `PowerShell`, and press Enter. (Command Prompt also works.)
3. **Check that Python works:**
   ```powershell
   py --version
   ```
   You should see something like `Python 3.13.x`.
4. **Install Clingo:**
   ```powershell
   py -m pip install clingo
   ```
5. **Check that Clingo works:**
   ```powershell
   py -m clingo --version
   ```
   You should see `pyclingo version 5.x.x`.

On Windows with pip, **use `py -m clingo` wherever this guide says `clingo`.**

#### Option B: conda (if you already use Anaconda or Miniconda)

1. Open **Anaconda Prompt** from the Start menu.
2. Install Clingo:
   ```powershell
   conda install -c conda-forge clingo
   ```
3. Check it:
   ```powershell
   clingo --version
   ```

This gives you a real `clingo` command, but only inside the Anaconda Prompt (or a terminal where that conda environment is active).

### macOS

#### Option A: Homebrew (recommended)

1. **Open Terminal.** Press `Cmd + Space`, type `Terminal`, and press Enter.
2. **Install Homebrew** if you don't have it. To check, run `brew --version`. If you get "command not found", install it with the one-line command at [brew.sh](https://brew.sh/), then follow the "Next steps" it prints to add `brew` to your PATH.
3. **Install Clingo:**
   ```bash
   brew install clingo
   ```
4. **Check it:**
   ```bash
   clingo --version
   ```
   You should see `clingo version 5.x.x`.

#### Option B: pip, in a virtual environment

Recent macOS Python installs block `pip install` into the system Python with an "externally-managed-environment" error. A virtual environment avoids that.

1. Open Terminal and go to the repo folder (see [Getting the files](#getting-the-files)).
2. Create and activate a virtual environment, then install Clingo:
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   pip install clingo
   ```
3. Check it:
   ```bash
   python -m clingo --version
   ```

Each time you open a new terminal, run `source .venv/bin/activate` again before using Clingo. With this option, **use `python -m clingo` wherever this guide says `clingo`.**

#### Option C: conda

If you use Anaconda or Miniconda, run `conda install -c conda-forge clingo` and then `clingo --version`.

### Linux

#### Option A: your package manager

**Debian / Ubuntu / Linux Mint:** the package is called `gringo`, but it includes the `clingo` command.

```bash
sudo apt update
sudo apt install gringo
clingo --version
```

**Fedora:**

```bash
sudo dnf install clingo
clingo --version
```

Distribution packages can be a few versions behind. Both programs in this repo work fine on any Clingo 5.x.

#### Option B: pip, in a virtual environment

This works on any distribution and gets you the latest version. Newer distributions (Ubuntu 23.04+, Debian 12+, Fedora 38+) block a bare `pip install` with an "externally-managed-environment" error, so use a virtual environment:

```bash
# Ubuntu/Debian only, if venv is missing:  sudo apt install python3-venv
python3 -m venv .venv
source .venv/bin/activate
pip install clingo
python -m clingo --version
```

Run `source .venv/bin/activate` again in each new terminal. With this option, **use `python -m clingo` wherever this guide says `clingo`.**

#### Option C: conda

`conda install -c conda-forge clingo`, then `clingo --version`.

### No install: run it in your browser

Potassco hosts a browser version of Clingo at **[potassco.org/clingo/run](https://potassco.org/clingo/run/)**.

1. Open the page.
2. Paste in the contents of a solver file (for example, `sudoku_simple_3liner.lp`).
3. Below that, paste in the contents of a puzzle file (for example, `boards/featured.lp`).
4. Click **Run**.

The browser version is fine for trying things out. A local install is faster and lets you run the files directly.

---

## Running the solver

### Getting the files

Either **clone** the repo with git:

```bash
git clone <this-repo's-URL>
cd <repo-folder>
```

or click the green **Code** button on GitHub, choose **Download ZIP**, unzip it, and open a terminal in that folder.

> **Opening a terminal in a folder:**
> - **Windows:** open the folder in File Explorer, click the address bar, type `powershell`, and press Enter.
> - **macOS:** right-click the folder in Finder and choose **New Terminal at Folder**. If you don't see it, enable it under System Settings → Keyboard → Keyboard Shortcuts → Services.
> - **Linux:** most file managers have **Open in Terminal** on the right-click menu. Otherwise, use `cd path/to/folder`.

### The command

The basic form is:

```
clingo <solver file> <puzzle file>
```

**macOS / Linux:**

```bash
clingo sudoku_simple_3liner.lp boards/featured.lp
```

**Windows (pip install):**

```powershell
py -m clingo sudoku_simple_3liner.lp boards\featured.lp
```

To use the 4-line solver, swap in its filename:

```bash
clingo sudoku_simple.lp boards/featured.lp
```

To solve a different puzzle, change the second filename:

```bash
clingo sudoku_simple_3liner.lp boards/easy_1.lp
```

### Checking that a puzzle has only one solution

By default, Clingo stops after the first solution it finds. Add `0` at the end to make it look for **all** solutions:

```bash
clingo sudoku_simple_3liner.lp boards/featured.lp 0
```

If the summary at the bottom says `Models : 1`, the puzzle has exactly one solution. A well-made Sudoku always does.

For fun, run a solver with **no** puzzle file. Clingo will fill in a completely blank grid:

```bash
clingo sudoku_simple_3liner.lp
```

(No puzzle file means no `#show` line, so this also prints the `grp(...)` helper atoms.)

---

## Reading the output

A run looks like this (the answer line is shortened here):

```
clingo version 5.8.2
Reading from sudoku_simple_3liner.lp ...
Solving...
Answer: 1 (Time: 0.016s)
in(1,1,2) in(1,2,1) in(1,4,9) ... in(3,1,3) in(3,2,4) in(2,1,5) ...
SATISFIABLE

Models       : 1+
Calls        : 1
Time         : 0.016s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
CPU Time     : 0.011s
```

- **`Answer: 1`** is followed by the solution: 81 atoms, one per cell. Each `in(R,C,N)` reads the same way as in the puzzle files: row `R`, column `C` holds `N`.
- The atoms are **not in grid order**. The givens usually come first, followed by the cells Clingo filled in, in whatever order it found them. To read off one cell, search for its row and column, e.g. `in(5,3,` finds the number in row 5, column 3.
- **`SATISFIABLE`** means Clingo found a solution.
- **`UNSATISFIABLE`** means the puzzle has **no** solution, usually because the givens contradict each other or there's a typo in the puzzle file.
- **`Models : 1+`** means "found 1, and stopped looking." You may also see plain `Models : 1` when Clingo happened to finish the whole search anyway. With `0` on the command line, you always get an exact count.

---

## Making your own puzzle

1. Copy an existing puzzle file, e.g. `boards/featured.lp` → `boards/my_puzzle.lp`.
2. Delete the `in(...)` facts and write one for each given in your puzzle:
   - row first (1 = top), then column (1 = left), then the number;
   - end each fact with a period;
   - you can put several facts on one line, as the example files do.
3. Keep the `#show in/3.` line.
4. Run it:
   ```bash
   clingo sudoku_simple_3liner.lp boards/my_puzzle.lp 0
   ```

If you get `UNSATISFIABLE`, look for a mistyped given (for example, two of the same number in a row). If you get `Models : 2` or more, your puzzle has more than one solution, which usually means a given is missing.

---

## Troubleshooting

**`clingo: command not found`** (macOS/Linux) or **`'clingo' is not recognized...`** (Windows)

- If you installed with **pip**, there is no `clingo` command. Use `python -m clingo` (macOS/Linux, with your virtual environment activated) or `py -m clingo` (Windows).
- If you installed with **conda**, make sure you're in the Anaconda Prompt or that the conda environment is activated.
- If you installed with **Homebrew** and `brew` itself isn't found, finish the "Next steps" Homebrew printed at the end of its install, then open a new terminal.

**`error: externally-managed-environment`** when running `pip install`

Your system Python doesn't allow pip installs. Use the virtual environment steps in [macOS Option B](#option-b-pip-in-a-virtual-environment) or [Linux Option B](#option-b-pip-in-a-virtual-environment-1), or use Homebrew, apt, or conda instead.

**`'py' is not recognized`** (Windows)

Python isn't installed, or wasn't added to PATH. Re-run the Python installer, choose **Modify**, and make sure *Add Python to environment variables* is ticked. Then open a **new** PowerShell window.

**`could not open input file!`**

The terminal isn't in the repo folder, or a filename is misspelled. Run `ls` (macOS/Linux) or `dir` (Windows) and check that you can see the `.lp` files and the `boards` folder.

**`syntax error, unexpected ...`** after editing a puzzle file

A fact is probably missing its closing period, or has a stray character. Each given must look exactly like `in(3,7,5).`

---

## Learn more

- **What Is Answer Set Programming?** Lifschitz, AAAI 2008: <https://www.cs.utexas.edu/~vl/papers/wiasp.pdf>
- **Potassco User Guide** (the Clingo manual): <https://github.com/potassco/guide/releases/download/v2.2.0/guide.pdf>
- **Clingo = ASP + Control: Preliminary Report.** Gebser, Kaminski, Kaufmann, Schaub, 2014: <https://arxiv.org/abs/1405.3694>
- **Conflict-Driven Answer Set Solving: From Theory to Practice.** Gebser, Kaufmann, Schaub, *Artificial Intelligence* 2012: <https://www.cs.uni-potsdam.de/wv/publications/DBLP_journals/ai/GebserKS12.pdf>
- **Potassco ASP course slides (Solving):** <https://github.com/potassco-asp-course/course/releases/download/v1.11.6/solving.pdf>
- **Clingo on GitHub:** <https://github.com/potassco/clingo>
