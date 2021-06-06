# SaGe: A Preemptive SPARQL Server for Online Knowledge Graphs

**Authors:** Julien Aimonier-Davat (LS2N), Hala Skaf-Molli (LS2N), Pascal Molli (LS2N) and Thomas Minier

**Abstract**
In order to provide stable and responsive SPARQL endpoints to the community, public SPARQL endpoints enforce fair use policies. Unfortunately, long-running SPARQL queries cannot be executed under the fair use policy restrictions, providing only partial results. In this paper, we present SaGe, a SPARQL server based on the web preemption principle. Instead of stopping queries after a quota of time, SaGe suspends the current query and returns it to the user. The user is then free to continue executing the query from the point where it was stopped by simply returning the suspended query to the server. In this paper, we describe the current state of the SaGe server, including the latest advances on the expressiveness of the server and its ability to support updates.

# Experimental results

## Dataset and Queries

In our experiments, we re-use the RDF dataset and the
SPARQL queries from the [BrTPF](https://doi.org/10.1007/978-3-319-48472-3_48)
experimental study. The dataset contains 10M triples and we randomly picked 60
queries such that all queries complete at least in 30 minutes.

## Machine configuration

We run all our experiments on a `MacBook Pro` with a `2,3 GHz Intel Core i7`
processor, `16GB of RAM` and a `1TB SSD disk`.

## Plots

**Plot 1**: Backends execution time when running the `?s ?p ?o` query.

![](figures/spo_execution_times.png?raw=true)

**Plot 2**: Backends suspend/resume time for different triple pattern shapes.

![](figures/suspend_resume_times.png?raw=true)

**Plot 3**: Backends execution time when running the 60 `WatDiv` queries.

![](figures/execution_times.png?raw=true)

# Experimental study

## Dependencies

To run our experiments, the following softwares and packages have to be installed on your system.
* [Python3.7](https://www.python.org) with developpement headers
* [Virtualenv](https://pypi.org/project/virtualenv) (optional)
* [sage-engine](https://github.com/sage-org/sage-engine) with HDT, HBase and PostgreSQL dependencies
* [PostgreSQL](https://www.postgresql.org) for the PostgreSQL backend of SaGe
* [HBase](https://hbase.apache.org) for the HBase backend of SaGe

## Installation

Once all dependencies have been installed, clone this repository and install the project.

```bash
# clone the project repository
git clone https://github.com/JulienDavat/sage-backends-experiments.git
cd sage-backends-experiments
# create a virtual environement to isolate project dependencies
virtualenv sage-env
# activate the virtual environement
source sage-env/bin/activate
# install the main dependencies
pip install -r requirements.txt
```

## Preparation

```bash
# download datasets into the graphs directory
mkdir graphs && cd graphs
wget nas.jadserver.fr/thesis/projects/sage/datasets/watdiv10M.hdt
wget nas.jadserver.fr/thesis/projects/sage/datasets/watdiv10M.nt
cd ..
# download queries into the workloads directory
cd workloads
wget nas.jadserver.fr/thesis/projects/sage/queries/watdiv_workloads.gz
cd ..
# insert data into PostgreSQL
sage-postgres-init --no-index configs/sage/backends.yaml sage_psql
sage-postgres-put graphs/watdiv10M.nt configs/sage/backends.yaml sage_psql
sage-postgres-index configs/sage/backends.yaml sage_psql
# insert data into SQLite
sage-sqlite-init --no-index configs/sage/backends.yaml sage_sqlite
sage-sqlite-put graphs/watdiv10M.nt configs/sage/backends.yaml sage_sqlite
sage-sqlite-index configs/sage/backends.yaml sage_sqlite
# insert data into HBase
sage-hbase-init --no-index configs/sage/backends.yaml sage_hbase
sage-hbase-put graphs/watdiv10M.nt configs/sage/backends.yaml sage_hbase
sage-hbase-index configs/sage/backends.yaml sage_hbase
# run the SaGe server
sage configs/sage/backends.yaml -w 1 -p 8080
```

## Running the experiments

Our experimental study is powered by **Snakemake**. The main commands used in our
experimental study are given below:

```bash
# Plot backends execution times for the ?s ?p ?o query
snakemake --cores 1 figures/spo_execution_times.png

# Plot backends suspend/resume times
snakemake --cores 1 figures/suspend_resume_times.png

# Plot backends execution times for a given WatDiv workload
snakemake --cores 1 figures/[workload directory]/execution_times.png
```
