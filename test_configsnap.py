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

    def whoami(self):
        """Return the calling function's name"""
        return inspect.stack()[1][3]

    def run_command(self, command):
        """Run a command and return output and exit code

        Args:
            param1 (str): the command to run

        Returns:
            list: stdout, stderr, exitcode
        """

        command_proc = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, cwd=self.cwd)
        output = command_proc.stdout.read()
        error = command_proc.stderr.read()
        returncode = command_proc.wait()

        return TestResult(output, error, returncode)

    def func1_dir(self):
        """Customised output directory; -d commandline option"""
        test = self.whoami()
        o = self.run_command('./configsnap -d /tmp/test -t functests')
        if o.retcode is not 0:
            print ("%s FAIL Exit code non-zero" % test)
        else:
            print ("%s PASS Exit code zero" % test)

        # Check that custom dir was created and has content
        if not os.path.isdir('/tmp/test'):
            print ("%s FAIL Custom dir doesn't exist" % test)
        else:
            print ("%s PASS Custom dir exists" % test)

        if len(os.listdir('/tmp/test')) < 1:
            print ("%s FAIL No files in custom dir" % test)
        else:
            print ("%s PASS Files in custom dir" % test)

    def func2_tag(self):
        """Customised tag; -t command line option"""
        ret = self.run_command('./configsnap -t randomalternativetag')

def main():
    f = FunctionalTests()
    functions = dir(f)
    for function in functions:
      if function.startswith('func'):
          getattr(f, function)()

if __name__ == "__main__":
    main()
