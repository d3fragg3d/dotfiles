#!/usr/bin/env python3
import calendar
import datetime
import os
import sys
import termios
import tty

RESET  = '\033[0m'
BOLD   = '\033[1m'
DIM    = '\033[2m'
YELLOW = '\033[1;33m'
CYAN   = '\033[1;36m'

def get_key():
    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        ch = sys.stdin.read(1)
        if ch == '\x1b':
            ch += sys.stdin.read(2)
        return ch
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)

def render(year, month):
    today = datetime.date.today()
    weeks = calendar.monthcalendar(year, month)
    title = datetime.date(year, month, 1).strftime('%B %Y')

    cols, _ = os.get_terminal_size()
    cal_width = 27
    left = ' ' * ((cols - cal_width) // 2)

    print('\033[2J\033[H', end='')
    print(f'{left}{BOLD}{CYAN}{title:^{cal_width}}{RESET}')
    print()
    print(f'{left}{BOLD}Mo  Tu  We  Th  Fr  Sa  Su{RESET}')
    print(f'{left}{"─" * cal_width}')

    for week in weeks:
        row = left
        for day in week:
            if day == 0:
                row += '    '
            elif today.year == year and today.month == month and today.day == day:
                row += f'{YELLOW}{BOLD}{day:2d}{RESET}  '
            else:
                row += f'{day:2d}  '
        print(row)

    print()
    nav = '←  prev      next  →      q  close'
    nav_pad = ' ' * ((cols - len(nav)) // 2)
    print(f'{nav_pad}{DIM}{nav}{RESET}')

year  = datetime.date.today().year
month = datetime.date.today().month

print('\033[?25l', end='', flush=True)  # hide cursor
try:
    while True:
        render(year, month)
        key = get_key()
        if key in ('q', 'Q', '\x03', '\r', '\n', ' '):
            break
        elif key == '\x1b[D':
            month -= 1
            if month < 1:
                month = 12
                year -= 1
        elif key == '\x1b[C':
            month += 1
            if month > 12:
                month = 1
                year += 1
finally:
    print('\033[?25h', end='', flush=True)  # restore cursor
    print('\033[2J\033[H', end='', flush=True)  # clear screen on exit
