set 'hosts', ['deploy@ec2-72-44-63-240.compute-1.amazonaws.com']
set 'repository', ['git://github.com/stuarts/Wedding-Invite.git']
set 'engine', []
set 'appPort', 80

namespace 'deploy', ->
    # show status of running application
    task 'status', ->
        run "sudo status #{roco.application}"

namespace 'npm', ->
  task 'install:coffee', (done)->
    run """
    npm install coffee-script -g
    """
    , done

namespace 'git', ->
    # setup remote private repo
    task 'remote', ->
        app = roco.application
        run """
        mkdir #{app}.git;
        cd #{app}.git;
        git --bare init;
        true
        """, (res) ->
            localRun """
            git remote add origin #{res[0].host}:#{app}.git;
            git push -u origin master
            """

# some tasks for monitoring server state
namespace 'i', ->
    task 'disk', (done) -> run 'df -h', done
    task 'top',  (done) -> run 'top -b -n 1 | head -n 12', done
    task 'who',  (done) -> run 'who', done
    task 'node', (done) -> run 'ps -eo args | grep node | grep -v grep', done
    task 'free', (done) -> run 'free', done

    task 'all', (done) ->
        sequence 'top', 'free', 'disk', 'node', done

    # display last 100 lines of application log
    task 'log', ->
        run "tail -n 100 #{roco.sharedPath}/log/#{roco.env}.log"
