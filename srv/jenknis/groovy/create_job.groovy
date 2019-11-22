import hudson.plugins.git.*;

// def scm = new GitSCM("git@github.com:0054/test.git")
def scm = new GitSCM("https://github.com/0054/test.git")
scm.branches = [new BranchSpec("*/master")];

// def flowDefinition = new org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition(scm, "Jenkinsfile")
def flowDefinition = new org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition(scm, "pipeline.jenkins")

def parent = Jenkins.instance
def job = new org.jenkinsci.plugins.workflow.job.WorkflowJob(parent, "New Job")
job.definition = flowDefinition

parent.reload()
