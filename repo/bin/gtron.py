#!/usr/bin/env python

import argparse
import sys
import subprocess
import os
import re
import json
import pipes
import shutil
import logging as log
import StringIO
import platform
import threading
"""


"""

dry_run = False;

class TermColors:
    HEADER = '\033[p5m'
    OKBLUE = '\033[p4m'
    GREEN = '\033[42m\033[97m'
    WARNING = '\033[97m'
#    WARNING = '\033[43m\033[97m'
    FAIL = '\033[41m\033[97m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def in_red(s):
    return TermColors.FAIL + s + TermColors.ENDC
def in_green(s):
    return TermColors.GREEN + TermColors.BOLD + s + TermColors.ENDC

def chdir(d):
    log.info("Entering '{}'".format(d))
    if dry_run:
        print "cd {}".format(d)
    else:
        try:
            os.chdir(d)
        except OSError as e:
            log.critical("Can't change to {}".format(d))
    
class Repo:

    order_count = 0;

    def __init__(self,json,  devel_root, local=False):
        try:
            old_wd = os.getcwd()
            os.chdir(devel_root)
            self.url = json["url"]
            self.container_directory = os.path.normpath(json["directory"])
            self.repo_directory = re.search(".*/([\{\}\$\w\-]*)(/$)?", self.url).group(1)
            t = os.path.relpath(os.path.normpath(os.path.abspath(os.path.join(self.container_directory, self.repo_directory))),
                                os.path.abspath(devel_root))
            self.full_directory = t
            self.absolute_path = os.path.abspath(os.path.join(devel_root,self.full_directory))
            #print devel_root
            #print self.full_directory
            print self.absolute_path
            self.stored_dep_wait = json.get("dep_wait")
            self.local = local

            if json.get("no_build") is not None:
                self.no_build = True if json.get("no_build").upper() == "TRUE" else False;
            else:
                self.no_build = False

            if json.get("branch") is not None:
                self.branch = json.get("branch")
            else:
                self.branch = None;

            if self.stored_dep_wait:
                Repo.order_count += 1

            self.sort_by = Repo.order_count;
        finally:
            os.chdir(old_wd)

    def to_json(self):
        r =  {"url": self.url,
              "directory": self.container_directory}
        if self.stored_dep_wait is not None:
            r["dep_wait"] = self.stored_dep_wait
        if self.no_build is True:
            r["no_build"] = "TRUE"
        if self.branch is not None:
            r["branch"] = self.branch
        return r

    def is_local(self):
        return self.local
    
    def expand_variables(self, workspace):
        self.url = workspace.eval_with_variables(self.url)
        self.container_directory = workspace.eval_with_variables(self.container_directory)
        self.repo_directory = workspace.eval_with_variables(self.repo_directory)
        self.full_directory = workspace.eval_with_variables(self.full_directory)
        
class WorkspaceConfig:

    def __init__(self,devel_root, global_config_file, local_config_file):
        self.load(devel_root, global_config_file, local_config_file)
        
    def reload(self):
        self.load(self.devel_root, self.global_config_file, self.local_config_file)

    def load(self,devel_root, global_config_file, local_config_file):
        global_json_data = json.load(open(global_config_file))
        if os.path.exists(local_config_file):
            local_json_data = json.load(open(local_config_file))
        else:
            local_json_data = {}
        
        self.global_config_file = global_config_file
        self.local_config_file = local_config_file
        self.devel_root = devel_root

        if global_json_data.get("vars") is not None:
            self.global_variables = global_json_data["vars"]
        else:
            self.global_variables = {}
            
        if local_json_data.get("vars") is not None:
            self.local_variables = local_json_data["vars"]
        else:
            self.local_variables = {}

        self.repo_map = {}
        if global_json_data.get("repos") is not None:
            for r in global_json_data["repos"]:
                n = Repo(r,local=False, devel_root=devel_root);
                self.add_repo(n);

        if local_json_data.get("repos") is not None:
            for r in local_json_data["repos"]:
                n = Repo(r, local=True, devel_root=devel_root);
                self.add_repo(n);

    def normalize_path(self, path):
        log.info(os.path.realpath(path))
        norm = re.sub("{}/?".format(self.devel_root), "", os.path.abspath(path))
        log.info("Normalized '{}' to '{}'".format(path, norm))
        return norm

    def path_relative_to_root(self, path):
        log.info(os.path.realpath(path))
        norm = os.path.relpath(path,self.devel_root)
        #norm = re.sub("{}/?".format(self.devel_root), "", os.path.abspath(path))
        log.info("Found dev_root relative path '{}' for '{}'".format(norm, path))
        return norm
            
    def absolute_path(self, path):
        return os.path.join(self.devel_root, path)
            
    def repos(self):
        return sorted(self.repo_map.itervalues(), cmp=lambda x,y: cmp(x.sort_by, y.sort_by));

    def get_repo_dirs(self):
        return map(lambda x: x.absolute_path, self.repos())

    def add_repo(self, r):
        log.info("Adding repo '{}' -> '{}'".format(r.full_directory, r.url))
        self.repo_map[r.full_directory] = r

    def remove_repo(self, r):
        del self.repo_map[r]

    def get_repo(self, directory):
        return self.repo_map.get(directory)
    
    def to_json(self, local=False):
        if local:
            return {"vars" : self.local_variables,
                    "repos" : [r.to_json() for r in self.repos() if r.is_local()]}
        else:
            return {"vars" : self.global_variables,
                    "repos" : [r.to_json() for r in self.repos() if not r.is_local()]}
            

    def expand_variables(self):
        for v in self.global_variables:
            self.global_variables[v] = self.eval_with_variables(self.global_variables[v])
        for v in self.local_variables:
            self.local_variables[v] = self.eval_with_variables(self.local_variables[v])
            
        repos = self.repos();
        self.repo_map={};
        for r in repos:
            r.expand_variables(self)
            self.add_repo(r)

    def get_variable(self, name):
        if self.local_variables.get(name) is None:
            return self.global_variables[name]
        else:
            return self.local_variables[name]
        
    def write_config_to_file(self, file, local=False):
        json.dump(self.to_json(local),
                  file,
                  sort_keys=True,
                  indent=4,
                  separators=(',', ': '))
        file.write("\n")

    def dump(self):
        self.write_config_to_file(sys.stdout, local=False)
        self.write_config_to_file(sys.stdout, local=True)
        
    def write_config(self):
        log.info("Writing out global config file '{}'...".format(self.global_config_file))
        if os.path.exists(self.global_config_file):
            shutil.copyfile(self.global_config_file, self.global_config_file + ".bak")
        self.write_config_to_file(open(self.global_config_file, "w"), local=False)

        log.info("Writing out local config file '{}'...".format(self.local_config_file))
        if os.path.exists(self.local_config_file):
            shutil.copyfile(self.local_config_file, self.local_config_file + ".bak")
        out =open(self.local_config_file, "w")
        self.write_config_to_file(out, local=True)
        out.close()
    

    def eval_with_variables(self, s):
        from string import Template
        last = ""
        new = s
        while last != new:
            last = new;
            t = Template(last).safe_substitute(self.local_variables)
            new = Template(t).safe_substitute(self.global_variables)
        return new

    def set_variable(self, key, value, local=False):
        if local:
            self.local_variables[key] = value
        else:
            self.global_variables[key] = value
            
    def unset_variable(self, key, local=False):
        try:
            if local:
                del self.local_variables[key]
            else:
                del self.global_variables[key]
        except:
            pass
        
class Command:
    @classmethod
    def setup(cls, subparsers, name, help, description):
        subparser = subparsers.add_parser(name, help=help, description=description)
        subparser.set_defaults(func=cls.go)
        cls.add_args(subparser)
    @classmethod
    def add_args(cls, parser):
        pass

class ParseAndDispatch:
    def __init__(self, app_desc, subp_title, subp_desc):
        self.parser = argparse.ArgumentParser(description=app_desc)
        self.subparsers = self.parser.add_subparsers(title=subp_title,
                                                     description=subp_desc)
    def add_command(self, cmd):
        cmd.setup(self.subparsers, cmd.__name__, cmd.help, cmd.description)

    def parse_args(self, argv):
        return self.parser.parse_args(argv)


class CmdFailure(Exception):
    def __init__(self, returncode, stdout, stderr):
        Exception.__init__(self);
        self.stdout = stdout
        self.stderr = stderr
        self.returncode = returncode
    def __str__(self):
        return "{}\n{}\nreturn code={}".format(self.stdout, self.stderr, self.returncode)
    
def do_cmd(s, stdout=sys.stdout, stderr=sys.stderr, stdin=sys.stdin, live_updates=False, raise_on_err=True, cwd=None, read_only=False):
    if dry_run is True and not read_only:
        output = ""
        print s
        return (None,None,None)
    else:
        if dry_run:
            print s
        
        log.info("Executing: " + s);
        if live_updates:
            p = subprocess.Popen(s, shell=True, stdout=stdout, stderr=stderr, stdin=stdin, cwd=cwd);
            (out, err) = p.communicate()
        else:
            p = subprocess.Popen(s, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=stdin, cwd=cwd);
            (out, err) = p.communicate()
            log.info("Stdout: \n" + str(out));
            log.info("stderr: \n" + str(err));
            
        if stdout is not None:
            if out is not None:
                stdout.write(out)
        if stderr is not None:
            if err is not None:
                stderr.write(err)

        if p.returncode is not 0:
            log.info("Command failed  ({})".format(s))
            if raise_on_err:
                raise CmdFailure(p.returncode, out, err)

        return (p.returncode, out, err)


class new_design(Command):
    """
    Create a new design.  It will will on github and will be added as a repo in
    the local configuration file.
    
    :param --name: the name of the design (no spaces) (required)
    :param --nvsl: Store it under the NVSL organization?  By default, store it under your github account.

    """
    description="Create a new gadgetron design."
    help="Create a new gadgetron design."
    @classmethod
    def add_args(cls, parser):
        parser.add_argument("--name",
                            required=True,
                            dest='name',
                            help="github username")
        parser.add_argument("--nvsl",
                            required=False,
                            default=False,
                            action='store_true',
                            dest='in_nvsl',
                            help="Create it under the NVSL organization")

    @classmethod
    def go(cls, workspace,args):
        template = workspace.get_variable("design_template");
        tail = os.path.basename(template)
        if os.path.exists(tail+".git"):
            log.error("Directory exists: {}.  Please remove it.".format(tail+".git"))
            sys.exit(1)

        if args.in_nvsl:
            (r, output, err) = do_cmd("""curl -s -u {} https://api.github.com/orgs/NVSL/repos -d '{{"name":"{}"}}'""".
                                      format(workspace.get_variable("github_user"), args.name))
        else:
            (r, output, err) = do_cmd("""curl -s -u {} https://api.github.com/user/repos -d '{{"name":"{}"}}'""".
                                      format(workspace.get_variable("github_user"), args.name))

        if not dry_run:
            response=json.loads(output)
            if response.get("errors") is not None:
                log.error("Couldn't create new repo: {}.".format(response["errors"][0]["message"]))
                sys.exit(1)
            log.info(output)
            new_repo = response["ssh_url"]
        else:
            new_repo = "NEW_REPO"
            
        do_cmd(workspace.eval_with_variables(("git clone --bare {template_repo} && " +
                                             "cd {tail}.git && "+ 
                                             "git push --mirror {new_repo}").format(tail=tail,template_repo=template, new_repo=new_repo)))
        do_cmd(workspace.eval_with_variables("rm -rf {tail}.git".format(tail=tail)))

        if not dry_run:
            workspace.add_repo(Repo({
                "directory":"Gadgets/Designs",
                "url" : new_repo,
                "order": 1000
            }, local=True))
            workspace.write_config()
        args.directories=["Gadgets/Designs/{name}".format(name=args.name)]
        args.branch="master"
        update.go(workspace,args)
        print "\nYou can create a .gspec file in {path}, and then do 'gtron build {path}'".format( path=args.directories[0])

    
class update_system(Command):
    """

    Update system-wide installations that this workspace requires.  This
    includes global python library like virtualenv, javascript utilities like
    node and npm, and applications like Eagle, Google App Engine, and Chrome.

    By default, just update python on node.  With :code:`--install-app`, install everything.

    """
    description="Update system-wide packagess that Gadgetron depends on"
    help="Update system for Gadgetron"
    @classmethod
    def add_args(cls, parser):
        parser.add_argument("--install-apps",
                            required=False,
                            default=False,
                            action='store_true',
                            dest='install_apps',
                            help="Install eagle, chrome, GAE, etc.")

    @classmethod
    def go(cls, workspace, args):
        if args.install_apps:
            do_cmd("update_system.sh --install", live_updates=True)
        else:
            do_cmd("update_system.sh", live_updates=True)
                        
class setup_devel(Command):
    """
    Perform initial configuration for the workspace (it runs :code:`repo/bin/setup_gadgetron.sh`).  This includes three tasks:

    1.  Initialized :code:`Workspace.local.json`.
    2.  Setup the python virtual environment for the workspace.
    3.  Build CGAL.

    :param --nvsl-user: NVSL username (i.e., your name on the BB cluster)
    :param --github-user:  Your username on github
    """
   
    description="Setup the development environment."
    help="Setup the devel environment.  You should only need to do this once."
    
    @classmethod
    def add_args(cls, parser):
        parser.add_argument("--nvsl-user",
                            required=False,
                            dest='nvsl_user',
                            help="NVSL username")
        parser.add_argument("--github-user",
                            required=False,
                            dest='github_user',
                            help="github username")

    @classmethod
    def go(cls, workspace, args):
        do_cmd("setup_gadgetron.sh {} {}".format(args.nvsl_user, args.github_user), live_updates=True)

class DirectoryCommand(Command):
    log_file_prefix="command"
    needs_log=True
    pretty_print=True
    auto_all=True
    enforce_dependencies = False
    auto_parallel = True

    @classmethod
    def add_args(cls, parser):
        parser.add_argument("--doall",
                            action="store_true",
                            help="Run command in all repos")
        parser.add_argument("--failstop",
                            action="store_true",
                            help="Stop running if there's a failure")
        parser.add_argument("--parallel",
                            action="store_true",
                            help="Run all the jobs at once")
        parser.add_argument("--serial",
                            action="store_true",
                            help="Run the jobs serially")
        parser.add_argument("--enforce_deps",
                            action="store_true",
                            help="Enforce dependencies during parallel execution")
        parser.add_argument("directories",
                            nargs="*",
                            help="Directories to operate on")
    @classmethod
    def pre_flight(cls, workspace, args):
        pass
        
    @classmethod
    def post_flight(cls, workspace, args):
        pass
        
    @classmethod
    def go(cls, workspace, args):
        oldPWD = os.getcwd()
        try:
            try:
                cls.pre_flight(workspace, args)
            except CmdFailure as e:
                log.error(e)
                raise e;
            workspace.expand_variables()

            if len(args.directories) == 0:
                if cls.auto_all or args.doall:
                    repo_list = workspace.repos()
                else:
                    args.directories = ["."]

            if len(args.directories) > 0:
                repo_list = []
                for d in map(workspace.path_relative_to_root, args.directories):
                    log.info("Running in {}".format(d))
                    r = workspace.get_repo(d)
                    if r is None:
                        log.warning("Couldn't find repo/directory in workspace config: '{}'.".format(d))
                        continue;
                    else:
                        repo_list.append(r)

            if args.parallel:
                c = 0
                order = repo_list[0].sort_by
                no_deps = not (cls.enforce_dependencies or args.enforce_deps)
                while c < len(repo_list):
                    threads = []
                    output = []
                    while c < len(repo_list) and (no_deps or repo_list[c].sort_by == order):
                        repo = repo_list[c]
                        out = StringIO.StringIO()
                        n = threading.Thread(target=cls.run_op,args=(args, repo, workspace, out));
                        log.debug("adding {}".format(repo.repo_directory))
                        threads.append(n)
                        output.append(out)
                        c += 1
                    if c < len(repo_list):
                        order = repo_list[c].sort_by

                    log.debug("running...")
                    for t in threads:
                        t.start()
                    for (out, t) in zip(output,threads):
                        t.join()
                        sys.stderr.write(out.getvalue())
            else:
                for repo in repo_list:
                    cls.run_op(args, repo, workspace)
        finally:
            os.chdir(oldPWD)
            cls.post_flight(workspace, args)

    @classmethod
    def run_op(cls, args, repo, workspace, err=sys.stderr):
        tmp_log_file_name = os.path.join(repo.container_directory,
                                         "{}-{}.gtron.log".format(repo.repo_directory, cls.log_file_prefix))
        try:
            os.makedirs(workspace.absolute_path(repo.container_directory))
        except OSError:
            if not os.path.isdir(workspace.absolute_path(repo.container_directory)):
                log.error("Couldn't create directory '{}'".format(workspace.absolute_path(repo.container_directory)))
                raise
        final_log_file_name = os.path.join(repo.full_directory,
                                           "{}.gtron.log".format(cls.log_file_prefix))
        if cls.needs_log and not dry_run:
            log_file = open(workspace.absolute_path(tmp_log_file_name), "w")
            log.info("Opened {} for logging".format(tmp_log_file_name))
        else:
            log_file = None
        try:
            preamble = "{} in {}: ".format(cls.log_file_prefix, repo.full_directory)
            preamble_s = len(preamble) if len(preamble) < 60 else 60
            postamble_format = "{:>" + str(60 - preamble_s) + "}[{}]\n"
            if not dry_run and cls.pretty_print:
                log.info(preamble);
                err.write(preamble)
            r = cls.directory_op(repo, workspace, args, log_file)
            if len(r) == 2:
                r = tuple(list(r) + [True])

            if not dry_run and cls.pretty_print and r[2]:
                success = r[0]
                msg = r[1]
                log.info(preamble);
                if success:
                    err.write(postamble_format.format("", in_green(msg)))
                else:
                    err.write(postamble_format.format("", in_red(msg)))
            if not dry_run and not r[2]:
                err.write("\r")

        except CmdFailure as e:

            if cls.needs_log:
                log_file.write(str(e))
            if not dry_run and cls.pretty_print:
                err.write(postamble_format.format("", in_red("FAILED")))
            if log_file is not None:
                log_file.close()
                log.warning("Last 10 lines of command output:")
                log.warning("".join(open(workspace.absolute_path(tmp_log_file_name), "r").readlines()[-10:]))

            if args.failstop:
                raise e;
        finally:
            if cls.needs_log and not dry_run:
                try:
                    os.rename(workspace.absolute_path(tmp_log_file_name),
                              workspace.absolute_path(final_log_file_name));
                    log.info("Moved {} to {}.".format(tmp_log_file_name, final_log_file_name))
                except Exception as e:
                    log.info("Couldn't move {} to {}.".format(tmp_log_file_name, final_log_file_name))
                    raise e;


class cmd(DirectoryCommand):
    """
    Run a shell command in all the repos.
    
    :param --cmd:  The command to run.
    """
    description="Run a shell command in all the repos."
    help="Run a shell command in all the repos."
    needs_log=False
    pretty_print=False

    @classmethod
    def add_args(cls, parser):
        parser.add_argument(dest='cmd',
                            nargs=1,
                            help="Shell command")
        parser.add_argument('--bare',
                            action='store_true',
                            help="Don't print anything other command output.")
        DirectoryCommand.add_args(parser)

            
    @classmethod
    def directory_op(cls, repo, workspace, args, log_file):

        if not args.bare:
            print "============ {} ============".format(repo.full_directory)
        do_cmd("cd {}; {}".format(workspace.absolute_path(repo.full_directory),args.cmd[0]))
        return (True, "Success")

            

class update(DirectoryCommand):
    """

    Update all the repos with :code:`git update`.

    :param --branch: Move to the branch provided.
    :param --default-branch: Move to the branch set in the configuration file.
    
    """
    description="Update all the devel directories"
    help="Get latest updates"
    log_file_prefix="update"

    @classmethod
    def add_args(cls, parser):
        DirectoryCommand.add_args(parser)
        parser.add_argument("--branch",
                            default=None,
                            help="Branch to checkout (git only)")

        parser.add_argument("--default-branch",
                            default=False,
                            action="store_true",
                            dest="restore_default_branch",
                            help="Restore repos to the branch specified in workspace configs.")

    @classmethod
    def pre_flight(cls, workspace, args):
        (r, out, err) = do_cmd("git pull", cwd=workspace.devel_root, stdout=None, stderr=None, raise_on_err=False)
        if dry_run:
            return
        if r is not 0:
            if err.find("There is no tracking information for the current branch") is not -1:
                log.warn("Couldn't pull updates for gtron because branch doesn't exist in upstream")
            else:
                raise CmdFailure(r, out, err)
        else:
            workspace.reload()
            
    
    @classmethod
    def directory_op(cls, repo, workspace, args, log_file):
        try:
            success_message="SUCCESS"
            if dry_run:
                print "Create directory {}, if needed.".format(repo.container_directory)
            else:
                try:
                    path = os.path.join(workspace.devel_root, repo.container_directory)
                    log.info("Making directory {}".format(path))
                    os.makedirs(path)
                except OSError as e:
                    if not os.path.isdir(os.path.join(workspace.devel_root, repo.container_directory)):
                        log.error("Couldn't make directory {}.".format(repo.container_directory))
                        success_message = "COULD NOT MAKE DIR"
                        raise e


            if args.branch is not None:
                branch = args.branch
            elif repo.branch is not None:
                branch = repo.branch
            elif workspace.get_variable("default_branch") is not None:
                branch = workspace.get_variable("default_branch")
            else:
                branch = "master"

            if os.path.isdir(os.path.join(workspace.devel_root, repo.full_directory)):
                log.info("Directory exists...updating")
                wd = workspace.absolute_path(repo.full_directory)
                #chdir(workspace.absolute_path(repo.full_directory))

                if args.restore_default_branch or args.branch is not None:
                    do_cmd("cd {}; git checkout {}".format(wd, branch),
                           stdout=log_file, 
                           stderr=log_file)
                (r, out, err) = do_cmd("cd {}; git pull".format(wd), raise_on_err=False, stdout=log_file, stderr=log_file)
                if not dry_run:
                    if err.find("There is no tracking information for the current branch") is not -1:
                        success_message = "MISSING UPSTREAM BRANCH"


            else:
                log.info("Directory doesn't exist...checking out")
                wd = workspace.absolute_path(repo.container_directory)
                #chdir(workspace.absolute_path(repo.container_directory))
                log.info("in " + os.getcwd())
                do_cmd("cd {}; git clone -b {} {}".format(wd, branch, repo.url), stdout=log_file, stderr=log_file)
                do_cmd("cd {}; test -d {}".format(wd,repo.repo_directory), stdout=log_file, stderr=log_file)

            if not dry_run:
                return (True, success_message)
            else:
                return (True, "")
            

        except Exception as e:
            if not dry_run:
                log_file.write(str(e))
                return (False, "FAILED")
            else:
                log.exception(e)
                raise e

class push(DirectoryCommand):
    """

    push all the repos.  Only for git, does :code:`git push`.

    """
    description="'git push' all directories."
    help="Push changes to mastetr"
    log_file_prefix="push"

    @classmethod
    def pre_flight(cls, workspace, args):
        (r, out, err) = do_cmd("git push", cwd=workspace.devel_root, stdout=None, stderr=None, raise_on_err=False)
        if dry_run:
            return
        if r is not 0:
            if err.find("There is no tracking information for the current branch") is not -1:
                log.warn("Couldn't pull updates for gtron because branch doesn't exist in upstream")
            else:
                raise CmdFailure(r, out, err)
                
    @classmethod  
    def directory_op(cls, repo, workspace, args, log_file):
        try:
            success_message="SUCCESS"
            if os.path.isdir(os.path.join(workspace.devel_root, repo.full_directory)):
                log.info("Directory exists...updating")
                #chdir(workspace.absolute_path(repo.full_directory))

                (r, out, err) = do_cmd("cd {};git push".format(workspace.absolute_path(repo.full_directory)),
                                       stdout=log_file, 
                                       stderr=log_file)
                if not dry_run:
                    if err.find("There is no tracking information for the current branch") is not -1:
                        success_message = "MISSING UPSTREAM BRANCH"
            return (True, success_message, True)
            
        except Exception as e:
            if not dry_run:
                log_file.write(str(e))
                return (False, "FAILED", True)
            else:
                log.exception(e)
                raise e

class ubt(DirectoryCommand):
    """Update, build, and test all the repos.  Equivalent to

.. code-block:: shell
      
    gtron update
    gtron build
    gtron test
"""
    description="Update, build, and test all the repos."
    help="Update, build, and test all the repos."

    @classmethod
    def add_args(cls, parser):
        update.add_args(parser)
        #build.add_args(parser)
        #test.add_args(parser)
    
    @classmethod
    def go(cls, workspace, args):
        update.go(workspace,args)
        build.go(workspace,args)                
        test.go(workspace,args)                

class make(DirectoryCommand):
    """ Run :code:`make` in all the repos.

    You can pass arguments to :code:`make` with the :code:`--args` flag.
    
    """

    description="Run arbitrary 'make' command in each repo"
    help="Run make everywhere"
    log_file_prefix="make"
    
    @classmethod
    def add_args(cls, parser):
        DirectoryCommand.add_args(parser)
        parser.add_argument("--args",
                            nargs="+",
                            dest='make_args',
                            default=[],
                            help="Arguments for 'make'")

    @classmethod
    def directory_op(cls, repo, workspace, args, log_file):
        #chdir(workspace.absolute_path(repo.full_directory))
        make_cmd= "make {}".format(" ".join(map(pipes.quote, args.make_args))).strip()
        if (os.path.exists(workspace.absolute_path(os.path.join(repo.full_directory, "makefile"))) or
            os.path.exists(workspace.absolute_path(os.path.join(repo.full_directory, "Makefile")))):
            do_cmd("cd {}; {}".format(workspace.absolute_path(repo.full_directory), make_cmd),
                   stdout=log_file,
                   stderr=log_file)
            return (True, "SUCCESS")
        else:
            return (True, "No Makefile")

class build(make):
    """ Build all the repos.  This is equivalent to 

.. code-block:: shell
      
    gtron make --args clean
    gtron make
    
    """
    description="Run build in all the devel directories"
    help="Build everything"
    log_file_prefix="build"
    enforce_dependencies = True

    @classmethod
    def directory_op(cls, repo, workspace, args, log_file):
        if not repo.no_build:
            args.make_args=["clean"]
            clean_result = make.directory_op(repo, workspace, args, log_file)
            if not clean_result[0]:
                return clean_result
            
            args.make_args=[]
            build_result = make.directory_op(repo, workspace, args, log_file)
            return build_result
        else:
            return (True, "NO BUILD")

class list_repos(DirectoryCommand):
    """
    Print a list of all the repos.  With the :code:`--eval` option, expand variables first.
    """
    
    description="List repositories that are part of this workspace"
    help="List repositories"
    pretty_print=False
    
    @classmethod
    def add_args(cls, parser):
        parser.add_argument("--eval",
                            required=False,
                            action='store_true',
                            default=False,
                            help="Expand variables")
        parser.add_argument("--dirs",
                            required=False,
                            action='store_true',
                            default=False,
                            help="List directories only")
        parser.add_argument("--repos",
                            required=False,
                            action='store_true',
                            default=False,
                            help="List repos only")
        DirectoryCommand.add_args(parser)
        
    @classmethod
    def pre_flight(cls, workspace, args):
        if args.eval or args.repos:
            workspace.expand_variables()
        
    @classmethod
    def directory_op(cls, repo, workspace, args, log_file):
        if args.dirs:
            print "{}".format(repo.full_directory)
        elif args.repos:
            print "{}".format(repo.url)
        else:
            print "{}: {}".format(repo.full_directory, repo.url)
        return (True, "")

class config_lint(Command):
    description="Parse and writout workspace.json"
    help="Check config syntax"
    @classmethod
    def go(cls, workspace, args):
        pass

class config_set(Command):
    """Set a variable in the configuration file.
    
    It takes a key-value pair as two positional parameters.  For example:

    .. code-block:: shell
    
      gtron config_set foo bar
    
    Sets variable :code:`foo` to :code:`"bar"`.  You can include variables in the
    value, but make sure you escape them properly, or the shell will expand them before gtron gets them.
    """
    
    description="Set variable value in config file"
    help="Set variable in config file"

    @classmethod
    def add_args(cls, parser):
        parser.add_argument("kv",
                            nargs=2,
                            metavar=("variable", "value"),
                            help="Set <variable>=<value>")
        parser.add_argument("--global",
                            required=False,
                            default=True,
                            dest="local",
                            action="store_false",
                            help="Add this to global config")
        
    @classmethod
    def go(cls, workspace, args):
        workspace.set_variable(args.kv[0], args.kv[1], local=args.local)
        workspace.write_config()

class add_repo(Command):
    """Add a repo to the workspace.
    
    :param --repo: Git URL for the repo.
    :param --direcotry: Directory that the repo should reside in.
    
    """
    description="Add a repository to checkout as part of this workspace"
    help="Add a repository"

    @classmethod
    def add_args(cls, parser):
        parser.add_argument("--repo",
                            required=True,
                            dest="repo",
                            help="Repository URL")
        parser.add_argument("--directory",
                            required=True,
                            dest="directory",
                            help="Directory where the repo should live")
        parser.add_argument("--global",
                            required=False,
                            default=True,
                            dest="local",
                            action="store_false",
                            help="Add this to global config")

    @classmethod
    def go(cls, workspace, args):
        workspace.add_repo(Repo({"url": args.repo, "directory":args.directory}, local=args.local))
        workspace.write_config()

class remove_repo(Command):
    """
    Remove a repo.
    
    :param --directory: The repo directory to remove.

    """
    
    description="Remove a repository to checkout as part of this workspace"
    help="Remove a repository"

    @classmethod
    def add_args(cls, parser):
        parser.add_argument("--directory",
                            required=True,
                            dest="directory",
                            help="Directory holds the contents of the repo")
        
    @classmethod
    def go(cls, workspace, args):
        found = False
        if workspace.get_repo(args.directory) is not None:
            workspace.remove_repo(args.directory)
        else:
            log.error("Couldn't find repo that lives in {}.".format(args.directory))
            sys.exit(1)
        workspace.write_config()

class config_unset(Command):
    """
    Remove a variable from the configuration file.  It takes the name of the variable as a single parameter.
    """
    description="Remove variable from config file"
    help="Remove variable from config file"

    @classmethod
    def add_args(cls, parser):
        parser.add_argument("k",
                            metavar="variable",
                            help="Variable to remove")
        parser.add_argument("--global",
                            required=False,
                            default=True,
                            dest="local",
                            action="store_false",
                            help="Add this to global config")
                
    @classmethod
    def go(cls, workspace, args):
        workspace.unset_variable(args.k, local=args.local)
        workspace.write_config()

class config_cleanup(Command):
    """
    Reformat the configuration files by loading them and writing them back out.
    """
    description="Reformat config file"
    help="Reformat config file"
    @classmethod
    def go(cls, workspace, args):
        workspace.write_config()

class config_dump(Command):
    """
    Parse the configuration files and print them out.
    
    :param --expand: Expand variable before displaying the configuration.

    """
    description="Parse, re-serialize, and print config file"
    help="Print config file"

    @classmethod
    def add_args(cls, parser):
        parser.add_argument("--expand",
                            required=False,
                            default=False,
                            action="store_true",
                            dest="expand",
                            help="Expand all variables")

    @classmethod
    def go(cls, workspace, args):
        if args.expand:
            workspace.expand_variables()
        json.dump(workspace.to_json(), sys.stdout,
                  sort_keys=True,
                  indent=4,
                  separators=(', ', ' : '))

class diff(DirectoryCommand):
    """Run 'diff' an all the repos. """
    description="""Run 'diff' an all the repos. """
    help="Run diff of each repo."
    needs_log=False
    pretty_print=False
    
    @classmethod
    def directory_op(cls, repo, workspace, args, log_file):
        #chdir(workspace.absolute_path(repo.full_directory))
        sys.stdout.write("{:=^80}\n".format(repo.full_directory))
        sys.stdout.flush()
        do_cmd("cd {};git --no-pager diff".format(workspace.absolute_path(repo.full_directory)))
        return (True, None)

class status(DirectoryCommand):
    """Run status command on all the repos.  'status' gives slightly different information for  git, so you'll need to make sense of that."""
    description="Run status command on all the repos.  'status' gives slightly different information for git, so you'll need to make sense of that."
    help="Run 'status' on each repo"
    needs_log=False
    pretty_print=False

    @classmethod
    def directory_op(cls, repo, workspace, args, log_file):
        #chdir(workspace.absolute_path(repo.full_directory))
        sys.stdout.write("{:=^80}\n".format(repo.full_directory))
        sys.stdout.flush()
        do_cmd("cd {};git status".format(workspace.absolute_path(repo.full_directory)))
        return (True, None)

class sanity_check(Command):
    description="Run a sanity check on the environment"
    help="Run sanity check"
    @classmethod
    def go(cls, workspace, args):
        pass # it's a noop, becaue we always run a sanity check.

class cleanup(Command):
    """Cleanup all the log files that gtron creates."""
    
    description="Cleanup all the files that gtron creates"
    help="Cleanup after gtron"
    @classmethod
    def go(cls, workspace, args):
        do_cmd("find . -name '*.gtron-log'| xargs rm -rf")

class full_docs(Command):
    """Build and open the manual in a web browser"""
    description="Build the html docs and open them"
    help="Build the html docs and open them"
    @classmethod
    def go(cls, workspace, args):
        directory=workspace.absolute_path("repo/doc")
        if platform.system() == "Darwin":
            do_cmd("cd {} && make html && open _build/html/index.html".format(directory))
        elif platform.system() == "Linux":
            do_cmd("cd {} && make html && google-chrome _build/html/index.html".format(directory))

class test(make):
    """Run tests in all the repos.  Specifically, run 'make test'."""
    description="Run tests in all the repos."
    help="Run tests in all the repos."
    log_file_prefix="test"

    @classmethod
    def directory_op(cls, repo, workspace, args, log_file):
        args.make_args=["test"]
        result = make.directory_op(repo, workspace, args, log_file)
        if not result[0]:
            return (False, "FAILED")
        else:
            return (True, "SUCCESS")

def load_version():
    text = open("VERSION.txt", "r").read().split("\n")[0]
    text = text.strip()
    return text.split(".")

def has_uncommited_changes(wd):
    (j1, git_status, j2) = do_cmd("cd {}; git status".format(wd), stdout=None, stderr=None)
    if git_status is not None:
        if "Changes not staged for commit" in git_status:
            unstaged = True;
        else:
            unstaged = False;
    return unstaged

class release(DirectoryCommand):
    """Merge master into release"""
    description="Merge master into release"
    help="Merge dev branch into release branch"
    log_file_prefix="release"
    auto_all=False
    pretty_print = True;
    @classmethod
    def add_args(cls, parser):
        DirectoryCommand.add_args(parser)
        parser.add_argument("--dev_branch", default="master", help="Branch to treat as the development branch")
        parser.add_argument("--rel_branch", default="release", help="Branch to treat as the release branch")
        parser.add_argument("--force", action="store_true", help="Release even if there are no changes")
        parser.add_argument("--check", action="store_true", help="Just perform checks")
        
    @classmethod
    def directory_op(cls, repo, workspace, args, log_file):

        def version_gt(a, b):
            a = map(int, a);
            b = map(int, b);
            if a[0] > b[0]:
                return True;
            elif a[0] < b[0]:
                return False;
            elif a[1] > b[1]:
                return True;
            elif a[1] < b[1]:
                return False;
            elif a[2] > b[2]:
                return True;
            else:
                return False;
                    
        #chdir(workspace.absolute_path(repo.full_directory))
        wd = workspace.absolute_path(repo.full_directory)
        (j1, current_branch,j1)=do_cmd("cd {}; git rev-parse --abbrev-ref HEAD".format(wd, workspace.absolute_path(repo.full_directory)), stderr=None, stdout=None, read_only=True)
        current_branch =current_branch.strip()
        if current_branch != args.dev_branch:
            return (False, "Wrong Branch: {}; should be {}".format(current_branch, args.dev_branch))

        # on the dev branch
        (LOCAL, REMOTE,BASE, junk) = check_up_to_date(wd);

        try:
            if LOCAL != REMOTE:
                return (False, "{} need pull and/or push".format(args.dev_branch))
            if has_uncommited_changes(wd):
                return (False, "{} needs commit".format(args.dev_branch))

            # check if the two version have diverged
            (j2, DEV,j3)=do_cmd("cd {}; git rev-parse {}".format(wd,args.dev_branch), stderr=None, stdout=None, raise_on_err=False, read_only=True)
            (j2, REL,j3)=do_cmd("cd {}; git merge-base {} {}".format(wd, args.dev_branch, args.rel_branch), stderr=None, stdout=None, raise_on_err=False, read_only=True)

            if DEV == REL and not args.force:
                return (True, "No release needed")

            # Make sure the old version is different than the new
            (j1, dev_version, j2) =  do_cmd('cd {}; git show HEAD:VERSION.txt'.format(wd), read_only=True, stdout=None)
            (j1, release_version, j2) =  do_cmd('cd {}; git show {}:VERSION.txt'.format(wd, args.rel_branch), read_only=True, stdout=None)
            dev_version = dev_version.strip()
            release_version = release_version.strip()
            dv = dev_version.split(".")
            rv = release_version.split(".")

            if not version_gt(dv, rv):
                return (False, "Dev version too low")

                        
            # switch to release branch
            do_cmd("cd {}; git checkout {}".format(wd, args.rel_branch),stderr=None, stdout=None)

            (LOCAL, REMOTE,BASE, junk) = check_up_to_date(wd);
            if LOCAL != REMOTE:
                return (False, "{} Not synced with origin".format(args.rel_branch))

            if args.check:
                return (True, "Ready to release")

            do_cmd("cd {}; git merge {}".format(wd, args.dev_branch), stderr=None, stdout=None)
            do_cmd("cd {}; git tag -a v{} -m 'version {}'".format(wd, dev_version, dev_version), stderr=None, stdout=None)
            do_cmd("cd {}; git push".format(wd), stderr=None, stdout=None)
            do_cmd("cd {}; git push origin v{}".format(wd, dev_version), stderr=None, stdout=None)

            return (True, "Success")
        finally:
            do_cmd('cd {}; git checkout {}'.format(wd, current_branch),stderr=None, stdout=None)




class bump_version(DirectoryCommand):
    """Increase version number"""
    description="Increase version number"
    help="Increase version number"
    auto_all=False
    log_file_prefix="bump_version"
    
    @classmethod
    def add_args(cls, parser):
        DirectoryCommand.add_args(parser)
        parser.add_argument("--patch", required=False, action='store_true', help="bump the last version number.")
        parser.add_argument("--minor", required=False, action='store_true', help="bump the middle version number.")
        parser.add_argument("--major", required=False, action='store_true', help="bump the major version number")
        parser.add_argument("--push", required=False, action='store_true', help="commit and push")

    @classmethod
    def directory_op(cls, repo, workspace, args, log_file):
        s = 0;
        if args.patch:
            s+=1
        if args.minor:
            s+=1
        if args.major:
            s+=1
        assert s == 1, "Must specify one of --major, --minor, or --patch"

        try:
            #chdir(workspace.absolute_path(repo.full_directory))
            wd =workspace.absolute_path(repo.full_directory)
            (major,minor,patch) = load_version()
            if args.patch:
                patch = int(patch) + 1

            if args.minor:
                minor = int(minor) + 1
                patch = 0

            if args.major:
                major = int(major) + 1
                minor = 0;
                patch = 0

            open("VERSION.txt", "w").write("{}.{}.{}\n".format(major,minor,patch))
            if args.push:
                do_cmd("cd {}; git commit -m 'Set version' VERSION.txt".format(wd), stdout=None, stderr=None)
                do_cmd("cd {}; git push".format(wd), stdout=None, stderr=None)
                
            return (True, "SUCCESS")
        except Exception as e:
            log.error(e)
            return (False, "FAILED")

def check_up_to_date(wd):
    (j1, LOCAL,j1)=do_cmd("cd {}; git rev-parse @".format(wd), stderr=None, stdout=None, read_only=True)
    (j2, REMOTE,rev_parse_err)=do_cmd("cd {}; git rev-parse @{{u}}".format(wd), stderr=None, stdout=None, raise_on_err=False, read_only=True)
    (j3, BASE,j3)=do_cmd("cd {}; git merge-base @ @{{u}}".format(wd), stderr=None, stdout=None, raise_on_err=False, read_only=True)
    return (LOCAL,REMOTE, BASE, rev_parse_err)

def get_branch(wd):
    (j, branch, j) = do_cmd('git rev-parse --abbrev-ref HEAD" {}'.format(wd), stdout=None, stderr=None)
    return branch.strip()

class stat(DirectoryCommand):
    """Intelligently check status for all repos"""
    description="Do intelligent status check"
    help="Do intelligent status check"
    log_file_prefx="stat"

    @classmethod
    def add_args(cls, parser):
        DirectoryCommand.add_args(parser)
        parser.add_argument("--update", required=False, action='store_true', help="Update remote state")
        parser.add_argument("-a", "--all", required=False, action='store_true', dest="show_all", help="show status for all repos, not just ones that need attention")


    @classmethod
    def directory_op(cls, repo, workspace, args, log_file):
        #chdir(workspace.absolute_path(repo.full_directory))
        wd = workspace.absolute_path(repo.full_directory)
        if args.update:
            do_cmd("cd {}; git remote update".format(wd), stdout=None, stderr=None)
        # see http://stackoverflow.com/questions/3258243/check-if-pull-needed-in-git

        (LOCAL,REMOTE,BASE, rev_parse_err) = check_up_to_date(wd)
        
        log.debug("LOCAL = {}".format(LOCAL))
        log.debug("REMOTE = {}".format(REMOTE))
        log.debug("BASE = {}".format(BASE))

        clean = True
        show = args.show_all
        
        if LOCAL == REMOTE:
            msg = "Up-to-date"
        elif LOCAL == BASE:
            clean = False
            show = True
            msg = "Need to pull"
        elif REMOTE == BASE:
            clean = False
            show = True
            msg = "Need to push"
        else:
            clean = False
            show = True
            msg = "Diverged"

        if "no upstream configured for branch" in rev_parse_err:
            clean = False
            show = True
            msg += "; Needs upstream branch"
            
        (j1, git_status, j2) = do_cmd("cd {}; git status".format(wd), stdout=None, stderr=None)
        if git_status is not None:
            r = git_status.find("Changes not staged for commit")
            if r is not -1:
                msg = msg + "; needs commit"
                clean = False;
                show = True
            r= re.search("On branch (\w+)",git_status)
            branch = r.group(1)
            msg = msg + " ({})".format(branch)

        return (clean, msg, show)
        
        
def sanity(workspace):

    #workspace.expand_variables()
    if os.environ.get("GADGETRON_ROOT") is None:
        log.warn("$GADGETRON_ROOT is not set.")
        return False;
    if os.path.dirname(os.environ.get("GADGETRON_ROOT")) != workspace.devel_root:
        log.warn("$GADGETRON_ROOT ({}) doesn't correspond to this workspace's root ({}).".format(os.environ["GADGETRON_ROOT"], workspace.devel_root))
        return False
    if os.path.dirname(sys.executable) != os.path.join(workspace.devel_root, "repo","venv","Gadgetron","bin"):
        #log.warn(os.path.dirname(sys.executable))
        #log.warn(os.path.join(workspace.devel_root, "repo","venv","Gadgetron","bin"))
        log.warn("Python executable ({}) is not in workspace virtual environment ({})".format(sys.executable,
                                                                                              os.path.join(workspace.devel_root,
                                                                                                           "repo",
                                                                                                           "venv",
                                                                                                           "Gadgetron")))
        return False
    return True;


def main():

    panda = ParseAndDispatch("Workspace manager for Gadgetron",
                             "Available commands",
                             "You can call these")

    panda.parser.add_argument("-n",
                              dest='dry_run',
                              default=False,
                              action='store_true',
                              help="Just print what would be done")


    panda.parser.add_argument("--root",
                              dest='devel_root',
                              default=dev_root,
                              help="Workspace root.  Default: {}".format(dev_root))

    panda.parser.add_argument("--config",
                              dest='global_config_file',
                              default=global_config,
                              help="Global configuration file to use.  Default: {}".format(global_config))

    panda.parser.add_argument("--local-config",
                              dest='local_config_file',
                              default=local_config,
                              help="Local configuration file to use.  Default: {}".format(local_config))

    panda.parser.add_argument("--force",
                              dest='force',
                              default=False,
                              action="store_true",
                              help="Perform actions even if your configuration seems strange")

    panda.parser.add_argument("--dump-after",
                              dest='dump',
                              default=False,
                              action="store_true",
                              help="Dump the contents of the config file after completing the command")

    panda.parser.add_argument("-v",
                              required=False,
                              action='store_true',
                              default=False,
                              dest='verbose',
                              help="Be verbose")
    panda.parser.add_argument("-vv",
                              required=False,
                              action='store_true',
                              default=False,
                              dest='very_verbose',
                              help="Be very verbose")

    panda.add_command(full_docs)
    panda.add_command(update)
    panda.add_command(push)
    panda.add_command(build)
    panda.add_command(test)
    panda.add_command(ubt)
    panda.add_command(diff)
    panda.add_command(status)
    panda.add_command(make)
    panda.add_command(cmd)
    panda.add_command(add_repo)
    panda.add_command(remove_repo)
    panda.add_command(new_design)
    panda.add_command(sanity_check)
    panda.add_command(cleanup)
    panda.add_command(stat)

    panda.add_command(bump_version)
    panda.add_command(release)
    
    panda.add_command(update_system)
    panda.add_command(setup_devel)
    panda.add_command(list_repos)
    panda.add_command(config_lint)
    panda.add_command(config_cleanup)
    panda.add_command(config_set)
    panda.add_command(config_unset)
    panda.add_command(config_dump)

    args = panda.parse_args(sys.argv[1:])

    if args.verbose:
        log.basicConfig(format="%(levelname)s: %(message)s", level=log.INFO)#DEBUG)
        log.info("Verbose output.")
    if args.very_verbose:
        log.basicConfig(format="%(levelname)s: %(message)s", level=log.DEBUG)
        log.debug("very Verbose output.")
    else:
        log.basicConfig(format="%(levelname)s: %(message)s")


    global dry_run;
    dry_run = args.dry_run;

    workspace = WorkspaceConfig(args.devel_root,
                                args.global_config_file,
                                args.local_config_file)
    if not args.force:
        if not sanity(workspace):
            log.error("Quiting, due to misconfiguration")
            sys.exit(1);
    
            #os.chdir(workspace.devel_root);
    args.func(workspace, args)
    if args.dump:
        workspace.dump()

if __name__ == "__main__":
    main()

dev_root = os.path.normpath(os.path.join(os.path.dirname(os.path.normpath(__file__)), "..", ".."))
global_config = os.path.join(dev_root, "repo", "config", "workspace.json")
local_config = os.path.join(dev_root, "repo", "config", "workspace.local.json")

theWorkspace = WorkspaceConfig(dev_root, global_config, local_config)