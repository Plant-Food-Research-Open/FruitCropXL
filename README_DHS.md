

DHS developers are using Jira and Bitbucket together with the intergrated features this provides.
To work with the functional-structural-apple-model repository in this way, clone the repository and
setup the remotes as follows: 

```bash
upstream  git@github.com:PlantandFoodResearch/functional-structural-fruit-crop-model.git
origin  git@bitbucket.org:plantandfood/functional-structural-fruit-crop-model.git
```

If you cloned the github repo and want to change to this setup, run the following commands:

```bash
> git remote rename origin upstream
> git remote add origin  git@bitbucket.org:plantandfood/functional-structural-fruit-crop-model.git
```

If you cloned from the DHS bitbucket repo, run:
```bash
> git remote add upstream  git@github.com:PlantandFoodResearch/functional-structural-fruit-crop-model.git

``` 


