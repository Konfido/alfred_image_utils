#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# --------------------------------------
# Created by Konfido on 2020-08-30
# --------------------------------------


import datetime
import json
import os
import shutil
import subprocess as sp
import sys

my_env = os.environ.copy()
my_env["PATH"] = "/usr/local/bin:" + my_env["PATH"]

for arg in sys.argv[1:]:
    file_dir = os.path.dirname(arg)
    file_id = datetime.datetime.now().strftime(format="%Y%m%d%H%M%S%f")[:-3]
    file_type = (os.path.splitext(arg)[-1]).lower()
    file_path = os.path.join(file_dir, file_id+file_type)
    os.rename(arg, file_path)
    try:
        if file_type == ".png":
            my_command = ["pngquant", file_path, "--quality",
                          "70-95", "--ext=.png", "--force"]
            sp.check_output(my_command, env=my_env)
        elif file_type == ".jpg" or file_type == ".jpeg":
            my_command = ["jpegoptim", "--max=90", file_path]
            sp.check_output(my_command, env=my_env)
        elif file_type == ".gif":
            my_command = ["gifsicle", "-i", file_path, "--optimize=3", "-o", file_path]
            sp.check_output(my_command, env=my_env)
    except Exception as e:
        print(e)

sys.stdout.write("All image compressed!")
