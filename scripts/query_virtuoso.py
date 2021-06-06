#!/usr/bin/python3

import logging
import coloredlogs
import click

from json import dumps
from time import time
from SPARQLWrapper import SPARQLWrapper, JSON
from utils import list_files, basename

coloredlogs.install(level='INFO', fmt='%(asctime)s - %(levelname)s %(message)s')
logger = logging.getLogger(__name__)


@click.command()
@click.argument('query', type=click.Path(exists=True, dir_okay=False, file_okay=True))
@click.argument('endpoint', type=str)
@click.argument('default-graph', type=str)
@click.option("--output", type=str, default=None,
    help="The file in which the source selection will be stored.")
@click.option("--measures", type=str, default=None,
    help="The file in which query execution statistics will be stored.")
def execute(query, endpoint, default_graph, output, measures):
    sparql = SPARQLWrapper(endpoint)
    sparql.setQuery(open(query, 'r').read())
    sparql.setReturnFormat(JSON)

    sparql.addParameter("default-graph-uri", default_graph)

    start_time = time()
    results = sparql.query()
    end_time = time() - start_time

    formatted_results = results.convert()

    if output is not None:
        with open(output, 'w') as output_file:
            output_file.write(dumps(formatted_results))
    # logger.info(f'\n{formatted_results}')

    if measures is not None:
        with open(measures, 'w') as measures_file:
            measures_file.write(f'{end_time},1,{len(formatted_results["results"]["bindings"])}')
    logger.info(f'Query complete in {end_time}s with 1 HTTP call. {len(formatted_results["results"]["bindings"])} solution mappings !')


if __name__ == "__main__":
    execute()
