const core = require('@actions/core');
const exec = require('@actions/exec');

async function run() {
    try {
        const mariadbVersion = core.getInput('mariadb-version');
        const dbUser = core.getInput('db-user');
        const dbPassword = core.getInput('db-password');
        const dbName = core.getInput('db-name');
        const src = __dirname;

        await exec.exec(`${src}/installMariadb.sh -v ${mariadbVersion} -u ${dbUser} -p ${dbPassword} -n ${dbName}`);
    } catch (error) {
        core.setFailed(error.message);
    }
}

run();