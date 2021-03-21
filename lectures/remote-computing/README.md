# Remote computing

This document contains a few tips on how to use the compute servers at QMUL. This is all based on a very approximate understanding of how it all works, so please feel free to correct/contribute!

---

**SSH**

First, you need to log into the servers. This is done via `ssh`, from your command line. The procedure to set everything up is detailed [here](http://support.eecs.qmul.ac.uk//services/ssh/). It should be fairly straightforward, but if you encounter any issues, you can email eecs-systems-team@lists.eecs.qmul.ac.uk.

Please note the distinction between *login* servers and *compute* servers. If you are using your own laptop, you first need to `ssh` into a login server before "hopping" onto a compute server, also with `ssh`.

Once you have set up SSH agent forwarding, as detailed in the page linked above, you should be able to run these commands to join the `epstein` compute server, for instance:

```bash
ssh -i ~/.ssh/id_rsa EECS_ID@frank.eecs.qmul.ac.uk -A
ssh epstein
```

Note that your `EECS_ID` is not the same as your QMUL ID. It's the one that includes letters and numbers (e.g., jdoe123).

To leave a server, just press `Ctrl` + `D`.

---

**SCP**

Unless you want to write code directly from the command line, you presumably have written a script on your local machine that you would like to run from the compute servers. This means you need a way to transfer your script and associated files to the server. This can be done in a variety of ways, including via `scp`, detailed below. For more information on SCP, see [here](https://linuxize.com/post/how-to-use-scp-command-to-securely-transfer-files/).

Note that there are different places where you can store files on the school servers. There are "scratch" spaces for temporary data on some servers, but a simpler way to do this is to keep your scripts and data in your `homes` folder. Note that this folder has an 80 GB quota for PhD students. See [here](http://support.eecs.qmul.ac.uk/services/disk-quota/) for what happens if you exceed your quota. You can check your quota by typing `quota` when logged in on any school server.

To copy a whole folder from the desktop of your local machine to your `homes` folder on the EECS servers:

```bash
scp -r ~/Desktop/my-experiment EECS_ID@frank.eecs.qmul.ac.uk:/homes/EECS_ID
```

And to copy data from the server back to your local machine, just do the reverse:

```bash
scp -r EECS_ID@frank.eecs.qmul.ac.uk:/homes/EECS_ID/my-experiment ~/Desktop
```

---

**Bash**

To navigate your files on the servers, you need to become familiar with a few bash commands. Mainly, `ls` to list the contents of the current directory, and `cd` to change directory. Basic bash commands are available [here](https://www.educative.io/blog/bash-shell-command-cheat-sheet), and arguments for each command are easily found with a simple Google search.

There are shortcuts for the current directory (`.`) and the parent directory (`..`). For instance, if you are starting from your `homes` folder and want to check the results of an experiment:

```bash
cd my-experiment/results # go to results folder
ls                       # list contents
cd ../..                 # return to homes folder
```

Be careful when deleting files/folders using `rm`, as you won't be prompted for confirmation, and deleted files can't be recovered.

A useful bash command allows you to redirect the terminal output to a log file. For more details, see [here](https://askubuntu.com/questions/38126/how-to-redirect-output-to-screen-as-well-as-a-file). For instance:

```bash
python my-script.py > logs/my-log.txt
```

---

**Servers**

Available compute servers are listed [here](http://support.eecs.qmul.ac.uk/research/compute-servers/), along with information about who can access them. If you are in the Music Cognition Lab, you most likely have access to EECS and C4DM servers. If you're looking for recommendations, I have used `epstein`, `hepworth`, `dorchester`, and `bath` in the past without making anyone too angry at me.

Before running a script on a compute server, check the available resources by typing `nvidia-smi`. This will give you some information about available memory and GPU usage. If they're too close to the limit, use another server.

Even if resources are available, you don't want to be inconsiderate when using them. When running your script, you should prepend it with `nice`. For instance:

```bash
nice python my-script.py
```

For extra arguments for `nice`, see [here](https://linux.die.net/man/3/nice).

---

**Screen**

It takes about as long to run a job on the compute server as it does on your local machine. The advantage is that long jobs can be left running on a server without making your machine unusable, and that you can run several jobs simultaneously, each using a core on a compute server.

This can be done using `screen`, detailed here, or also `nohup`, I believe. Roughly speaking, `screen` opens a new terminal window, from which you can run a job. This terminal window can be closed while leaving the job running in the background, which prevents it from getting interrupted if it takes too long, and allows you to run multiple jobs at the same time.

To create a `screen` and run a job:

```bash
screen -S my-task
nice python my-script.py
```

You can then close the screen by pressing `Ctrl` + `A` and then `Ctrl` + `D`. To check the progress of you script, you need to find the task number:

```bash
screen -ls      # list task names and associated numbers
screen -r 12345 # using a task number listed above
```

**IMPORTANT**: Once a task is done, you must kill the screen, or it will stay open and use server resources for nothing:

```bash
kill 12345
```

Keep in mind that you must be able to run your scripts directly from the command line, rather than from an IDE. See below for language-specific advice.

---

**Scripts**

As mentioned above, you need to be able to run your scripts from the command line, as you won't have access to an IDE. Here is some very basic advice for Python and MATLAB.

*Python*

Your script should be contained in a function, called if the script is run from the command line. In practice, it looks like this:

```python
# Required for command line arguments
import sys

# Function containing your entire script
def say_hello(first_name):
    print(f'Hello, {first_name}!')

# Called if executed from the command line
if __name__ == '__main__':
    n = sys.argv[1]           # arguments passed from command line
    say_hello(first_name = n) # main function here
```

You can then call your function from the command line:

```bash
python my-script.py 'Remi'
#> Hello, Remi!
```

There are several ways to handle environments, so that you can access the libraries you need. I like to use `miniconda`. This is done by loading modules once logged into a compute server. For details about modules, see [here](http://support.eecs.qmul.ac.uk//software/environment-modules/). For instance:

```bash
module load miniconda

conda create --name my-env
source activate my-env

conda install some-packages
pip install some-other-packages
```

You can then run your scripts from within your fresh Python environment. See [here](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html) for more details about managing environments.

*MATLAB*

I don't remember why, but I found it difficult to execute a MATLAB script with arguments from the command line. Unless you figure out how to do so, you can format you script as follows:

```matlab
% Full script, using undeclared variables
disp(['Hello, ', n, '!']);
```

You can then declare your arguments straight from the command line:

```bash
matlab -nodisplay -nodesktop -r "n = 'Remi'; run myscript.m"
#> Hello, Remi!
```

You can add toolbox folders in the same folder as your MATLAB script, and include them by adding the following lines in your script:

```matlab
addpath('my-toolbox-1')
addpath('my-toolbox-2')
```