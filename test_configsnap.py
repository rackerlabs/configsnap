#!/usr/bin/python

# Copyright 2016 Rackspace, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use
# this file except in compliance with the License.  You may obtain a copy of the
# License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations under the License.


# Functional tests

import inspect
import os
import re
import subprocess
import sys
import shutil


class TestResult:

    def __init__(self, stdout, stderr, retcode):
        # Remove ANSI color escape sequences from text
        ansi_escape = re.compile(r'\x1b[^m]*m')
        self.stdout = ansi_escape.sub('', stdout)
        self.stderr = ansi_escape.sub('', stderr)
        self.retcode = retcode

    def stdout(self):
        print self.stdout

    def stderr(self):
        print self.stderr

    def retcode(self):
        print self.retcode


class FunctionalTests:

    cwd = os.path.dirname(os.path.realpath(__file__))
    failurecount = 0

    def whoami(self):
        """Return the calling function's name"""
        return inspect.stack()[1][3]

    def failtest(self, test, text):
        print("%s FAIL %s" % (test, text))
        self.failurecount += 1

    def run_command(self, command):
        """Run a command and return output and exit code

        Args:
            param1 (str): the command to run

        Returns:
            list: stdout, stderr, exitcode
        """

        command_proc = subprocess.Popen(
            command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, cwd=self.cwd)
        output = command_proc.stdout.read()
        error = command_proc.stderr.read()
        returncode = command_proc.wait()

        return TestResult(output, error, returncode)

    def func1_customdir(self):
        """Customised output directory; -d commandline option"""
        test = self.whoami()
        o = self.run_command('./configsnap -d /tmp/test -t functests')
        if o.retcode is not 0:
            self.failtest(test, "Exit code non-zero")
        else:
            print("%s PASS Exit code zero" % test)

        # Check that custom dir was created and has content
        if not os.path.isdir('/tmp/test'):
            self.failtest(test, "Custom dir doesn't exist")
        else:
            print("%s PASS Custom dir exists" % test)

        if len(os.listdir('/tmp/test')) < 1:
            self.failtest(test, "No files in custom dir")
        else:
            print("%s PASS Files in custom dir" % test)

    def func2_customtag(self):
        """Customised tag; -t command line option"""
        test = self.whoami()
        o = self.run_command('./configsnap -t randomalternativetag')
        if o.retcode is not 0:
            self.failtest(test, "Exit code non-zero")
        else:
            print("%s PASS Exit code zero" % test)

        # Check tag name on dir
        if os.path.exists('/root/randomalternativetag'):
            print("%s PASS alternative tag dir exists" % test)
        else:
            self.failtest(test, "Alternative tag dir doesn't exist")

        if len(os.listdir('/root/randomalternativetag/configsnap')) < 1:
            self.failtest(test, "No files in collection dir")
        else:
            print("%s PASS Files in collection dir" % test)

    def func3_overwrite(self):
        """Overwrite workdir; -w command line option"""
        test = self.whoami()
        for i in range(1, 4):
            o = self.run_command('./configsnap -t overwrite -p pre -w')
            if o.retcode is not 0:
                self.failtest(test, "Exit code non-zero, run %i" % i)
            else:
                print("%s PASS Exit code zero, run %i" % (test, i))

    def func4_error_handling_nooverwrite(self):
        """Don't overwrite by default"""
        test = self.whoami()
        o = self.run_command('./configsnap -t nooverwrite -p pre')
        if o.retcode is not 0:
            self.failtest(test, "Exit code non-zero, initial run")
        else:
            print("%s PASS Exit code zero, initial run" % test)

        o = self.run_command('./configsnap -t nooverwrite -p pre')
        if o.retcode is not 1:
            print o.retcode
            self.failtest(test, "Exit code not 1, second run")
        else:
            print("%s PASS Exit code 1, didn't overwrite, second run" % test)


def main():
    """Clean root directory test files"""
    for test_dir in ["nooverwrite", "overwrite", "randomalternativetag"]:
        print("deleting /root/" + test_dir)
        shutil.rmtree(os.path.join("/root/", test_dir))

    f = FunctionalTests()
    functions = dir(f)
    for function in functions:
        if function.startswith('func'):
            getattr(f, function)()

    print("Tests complete; failures: %s" % f.failurecount)

    if f.failurecount != 0:
        sys.exit(1)

if __name__ == "__main__":
    main()
