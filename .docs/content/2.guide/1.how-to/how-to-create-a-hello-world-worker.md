# Hello, world - Worker in Python

::alert{type="warning"}
- Make sure you are using Python version 3.7 or superior. (check version) typing compatible?
- This part is complementary to the Hello world Client guide. Both are required.
::

What is a Worker?

In this section, you will learn how to create a **Worker** to check if your deployment is working and get accustomed to ArmoniK's logic.

You will find code excerpts of an actual Worker written in Python. Feel free to check out the worker.py file along this guide. (Add link here)

## Import modules

You can use a variety of modules and code already in place. In fact, you should as it will make coding your Workers easier. As for ArmoniK, there are modules ready to facilitate development.

First thing you need to do is import the necessary modules :

```python
import logging
import os
import grpc
from armonik.worker import ArmoniKWorker, TaskHandler, ClefLogger
from armonik.common import Output, TaskDefinition
from typing import List, Union, cast
from common import Payload, Result
```

(Est-il intéressant de détailler tout? Les modules doivent-ils impérativement être dans cet ordre?)

- logging: will be used for emitting logs messages, creating logs records, etc.
- os: will allow the Worker to communicate no matter the Operating Systems
- grpc: gRPC will serve as the communication channel.
- class: armonik.worker:
	- ArmonikWorker is the module that will deploy the worker itself. You will need to integrate a Seq compatible logger (not Fluentbit?): Cleflogger is here for this purpose.
	- ClefLogger : utilise un module pour faire remonter tous les messages de type INFO, WARNING, ERROR et CRITICAL. It is in charge of creating logs.
- armonik.common: FAUX : détailler plus will manage the outputs to make sure they are correctly received and received in the right format (à confirmer)
- typing: From the *typing* module, List indicates that the (what?) should be a list. Union indicates that (what?) is of a certain type (which one?). Cast will make sure that what is returned is a float value in our case.
- common: will manage the coming Payloads and Results sent.

For this example, all communications will use insecure channels. As your deployment will only run locally, there is no need for secure channels. (Securing communications is addressed in [add link to dedicated page])

## Tasks processing

Pour cette partie, il me semble que worker.py a trop d'éléments pour un simple Hello, world. J'aimerais savoir quelles sections du code inclure pour avoir un Worker fonctionnel.

```python
# Task processing
def processor(task_handler: TaskHandler) -> Output:
    logger = ClefLogger.getLogger("ArmoniKWorker")
    payload = Payload.deserialize(task_handler.payload)
    # No values
    if len(payload.values) == 0:
        if task_handler.expected_results:
            task_handler.send_result(task_handler.expected_results[0], Result(0.0).serialize())
        logger.info("No values")
        return Output()

    if isinstance(payload.values[0], str):
        # Aggregation task
        results = [Result.deserialize(task_handler.data_dependencies[r]).value for r in cast(List[str], payload.values)]
        task_handler.send_result(task_handler.expected_results[0], Result(aggregate(results)).serialize())
        logger.info(f"Aggregated {len(results)} values")
        return Output()

    if len(payload.values) <= 1 or len(payload.values) <= payload.subtask_threshold:
        # Compute
        task_handler.send_result(task_handler.expected_results[0], Result(aggregate(cast(List[float], payload.values))).serialize())
        logger.info(f"Computed {len(payload.values)} values")
        return Output()

    # Subtasking
    pivot = len(payload.values) // 2
    # Split payload in half
    lower = payload.values[:pivot]
    upper = payload.values[pivot:]
    # Create sub-results
    subresults = task_handler.get_results_ids([f"{task_handler.task_id}_lower", f"{task_handler.task_id}_upper"])
    subtasks = []
    for result_id, vals in [(subresults[f"{task_handler.task_id}_lower"], lower), (subresults[f"{task_handler.task_id}_upper"],upper)]:
        # Create new payloads and task definitions
        new_payload = Payload(values=vals, subtask_threshold=payload.subtask_threshold).serialize()
        subtasks.append(TaskDefinition(payload=new_payload, expected_output_ids=[result_id]))
    # Create the aggregation task
    aggregate_dependencies = [s.expected_output_ids[0] for s in subtasks]
    subtasks.append(TaskDefinition(Payload(values=aggregate_dependencies).serialize(), expected_output_ids=task_handler.expected_results, data_dependencies=aggregate_dependencies))

    # Submit tasks
    submitted, errors = task_handler.create_tasks(subtasks)
    if len(errors) > 0:
        message = f"Errors while submitting subtasks : {', '.join(errors)}"
        logger.error(message)
        return Output(message)
    logger.info(f"Submitted {len(submitted)} subtasks")
    return Output()


def aggregate(values: List[Union[int, float]]) -> float:
    return sum(values)
```

## Main

Your main function should now call for:
- creating a Keylogger
- Giving the endpoints for the couple Scheduling (Polling?) Agent - Worker
- start the Worker

```python
def main():
    # Create Seq compatible logger
    logger = ClefLogger.getLogger("ArmoniKWorker")
    # Define agent-worker communication endpoints
    worker_scheme = "unix://" if os.getenv("ComputePlane__WorkerChannel__SocketType", "unixdomainsocket") == "unixdomainsocket" else "http://"
    agent_scheme = "unix://" if os.getenv("ComputePlane__AgentChannel__SocketType", "unixdomainsocket") == "unixdomainsocket" else "http://"
    worker_endpoint = worker_scheme+os.getenv("ComputePlane__WorkerChannel__Address", "/cache/armonik_worker.sock")
    agent_endpoint = agent_scheme+os.getenv("ComputePlane__AgentChannel__Address", "/cache/armonik_agent.sock")

    # Start worker
    logger.info("Worker Started")
    with grpc.insecure_channel(agent_endpoint) as agent_channel:
        worker = ArmoniKWorker(agent_channel, processor, logger=logger)
        logger.info("Worker Connected")
        worker.start(worker_endpoint)


if __name__ == "__main__":
    main()
```


Pourquoi la fonction main n'appelle pas le reste des autres fonctions? Je suppose que le Worker fonctionne mais je ne comprends pas ce point.

Reste la question : où faut-il placer ce ficher pour que tout fonctionne?

