# rstudio-docker
A template for using Docker and RStudio on remote servers. Includes access to GitHub using SSH.

## Start RStudio on the remote server

SSH onto your remote server. Make sure you have installed the correct version of your project's docker container on the remote server. 

```
docker pull url-path-to-container:tag
```

You can start RStudio by using the following command. Replace PASSWORD with a password you will need to log into RStudio. 

```
bash rstudio.sh PASSWORD
```

RStudio server is now running and is connected to your terminal window. 

There are a variety of options for customizing the container:
* The `-p` flag changes the port used to access RStudio. You will need this information later. By default, the port is 8787.
* The `-m` flag changes how much RAM (in gigabytes) is allocated to Docker/RStudio. Enter a numeric value.
* The `-d` flag changes the directory the project is stored within. Setting this value means that you can find your project in the Docker container's ~/`-d` directory. The default value is the name of the current working directory (i.e. the name of the folder where the terminal is currently running).
* The 'r' flag adds the rstudio user to the list of users who can use the root sudo command. This flag accepts no values.

For example, I could set the server to be accessible from port 1234, allocate 12 gigabytes of RAM, make the project be found in the ~/my-project folder, and make the password `secret` with the following command.

```
bash rstudio.sh -p 1234 -m 12 -d my-project secret
```

## Connect your local machine to remote RStudio

Now, you need to set it up so your local machine can access the remote server. THis can be done with SSH port forwarding. Open a new terminal window without closing your old terminal. Enter the following command. You will want to replate 1234 with the port on your PC with which you'd like to access RStudio. You will need to change 0000 to the port RStudio is using on the remote host. This comes from the `-p` option. Finally, replace `user@server.com` with the adress of your remote server. Make sure to connect to any VPN you need to beforehand.

```
ssh -f -N -L 1234:localhost:0000 user@server.com
```

You can know access RStudio on the remote host opening your browser, and navigating to the following URL. Don't forge to replace 1234 with the port you set in the ssh command.

```
localhost:1234
```

You will be prompted to enter a username and password. The username is `rstudio` and the password is the option you set for PASSWORD when starting the server. 

## Setup RStudio and GitHub

RStudio has a built in ability to work with GitHub, but it requires additional steps to work with RStudio server and docker. This action only needs to be completed the first time you clone a repositroy. 

### 1. Create an SSH Key

Open the terminal on your local machine, and enter the following command. Enter something informative for the DESCRIPTION attribute. 

```
ssh-keygen -t ed25519 -C "DESCRIPTION"
```

The tool will ask the location to store the SSH key. Make not of this location since you will need to retrive the key later. 

The tool will also ask for a passphrase. You will need this passphrase to use the SSH key, and therfore to connect to your GitHub account. Make it something secure and strong. 

**Troubleshooting**

The Ed25519 algorithm is recommended by GitHub, but you may also use the rsa algorithm if you computer does not offer Ed25519.

```
ssh-keygen -t rsa -b 4096 -C "DESCRIPTION"
```

IF you computer does not include a tool for generating SSH keys, you can RStudio itself. RStudio include a tool for generating SSH keys. Go to Tools > Global Options > Git/Svn. You'll see a button to create an SSH key. 

### 2. Make SSH Key available to RStudio

In the project directory (where this file is located), create a folder named `.rstudio` if it doesn't already exist. Inside this directory, create another directory named `ssh` without any period in the name. 

Copy or move the SSH key from step 1 to the new `ssh` directory just created. Make sure to move both the private and public keys. 

Change the SSH private key file so only the user can read/write/execute. To do this, open the `ssh` folder in your terminal and enter the following command.

```
chmod 700 id_ed25519
```

Change `id_ed25519` to be the name of your private SSH key file. 

### 3. Let GitHub know about the SSH key

Open the public key in a plain text editor. This is the public SSH key. Add this key to your GitHub account. Here is the [GitHub documentation](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) on how to accomplish this task.

### 4. Configure GitHub client

Run RStudio server using the included start script. You will need to access the terminal. This can be accessed in RStudio by opening the `Console` pane, and clicking on the `Terminal` tab. 

Enter the following commands, adding the name and email assocaited with your GitHub account. 

```
git config --global user.name "John Doe"
git config --global user.email johndoe@example.com
```

## 5. Using GitHub

You can know use the RStudio interface to create, clone, and manage repositories. When connecting to GitHub, you will be asked to enter the passphrase you used to create the SSH key. 

If you attempt to use GitHub and get prompted to enter your GitHub username and password, this is a mistake and it will fail. 

IF this happens to you, open your terminal and navigate to the directory with your git repository. Enter the following command to change a repository to use SSH. Replace USERNAME with your GitHub username and REPOSITORY with the name of your repository.

```
git config remote.origin.url git@github.com:USERNAME/REPOSITORY.git
```

You can check the repository use the remote path for SSH by using the following command.

```
git remote -v
```

When cloning a repositroy, use the `git@github.com` url as well.

## Using this template

### Setting the container

When you first install the template, you will want to change the default container to the one for your project. You can open the rstudio.sh file, and change `CONTAINER=ghcr.io/kschaubroeck/rstudio-docker:main` to equal `CONTAINER=your-container:tag`

IF this is your first time running the template, it makes sens to use the default container, install some R packages, update the lock file, and push to GitHub. This will trigger GitHub actions to build a container. You can then change our default container int he rstudio.sh file. 

### GitHub actions

This template includes several GitHub action scripts designed to build Docker images and store them alongside your repository as a GitHub package. This action is automatic and does not require your attention. 

The container scripts fire under two conditions.

First: When branch `main` is updated, and the Dockerfile or renv.lock files have changed. If these files have not changed, then a new container will not be built.

Second: When a new tag (version) is released. Any tag in the form `v0.0.0` will trigger the creation of a Docker image even if the Dockerfile or renv.lock files have not changed. 
