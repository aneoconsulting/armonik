# Hello, world - Client in Python
::alert{type="warning"}
- Make sure you are using Python version 3.7 or superior. (check version)
- This part is complementary to the Hello world Worker guide. Both are required.
::

In this section, you will learn how to create a [Client](https://aneoconsulting.github.io/ArmoniK/armonik/glossary#client). This Client will be a simple script that you can execute from your terminal.

It will open a communication channel, a dedicated way to communicate quickly with the Control Plane. It will also create an instance (are we talking about the Submitter + Metrics exporter instance?), create a payload with the task and its metadata, a task ID, its options, then it will create a [session](https://aneoconsulting.github.io/ArmoniK/armonik/glossary#session) and finally send the task and the task’s ID with the state *created*.

The task and the task’s ID are separate for faster data management by ArmoniK. This way, the Control plane will ask if there is a task pending in the Data Plane, retrieve the task’s ID and call for the Compute Plane to collect this task and execute it. When the Compute Plane is done, it will send the task and the task’s ID to the Data Plane. Since the Control Plane continuously checks for the states of the tasks' IDs, when a task is done, it will detect it and tell the Client to retrieve it from the Data Plane.

Here you have the basics of ArmoniK's logic. So let's get started and create this Client and verify your deployment along the way.

## Import modules

Let's start with modules. You will use standard python modules, third-party modules and classes from ArmoniK.

You will need to import gRPC's library to communicate between your Client and the Submitter in the Control Plane. The gRPC module will allow for fast throughput as it sends binaries. It relieves you from the need of writing in a specific language. Once written, it will be able to communicate with the other components of ArmoniK. Lastly, the way the data are structured is less demanding on resources. It may not matter for this example but it will in the end.

If you do not have gRPC installed already, please install it.

```bash
$ python -m pip install grpcio
```

First thing you need to do is import the necessary modules:
```python
from typing import cast

import grpc
import argparse

from armonik.client import ArmoniKSubmitter, ArmoniKResult
from armonik.common import TaskDefinition, TaskOptions
from common import Payload, Result
```

from common import Payload, Result : fichier manquant
Distinguer entre modules, classes et objets.
Armonik : projet
common et modules contiennent des classes


Here is what each module is for:
- module par ArmoniK: Payload and Result will create payloads and results (and task IDs?)

- a parsing module to determine what arguments can be required. (develop?) NE DEVRAIT PAS ETRE LA.
- ArmoniKSubmitter and ArmoniKResult from armonik.client to respectively submit tasks and retrieve results.
- Class TaskDefinition and TaskOptions from armonik.common to respectively (voir avec Dylan) indicate the definition of your tasks and according to which options they should be treated.
- module timemodule: datetime and timedelta to specify the time of the tasks various states and the duration of those.

## Arguments

Before you call your Main function, this one will need the necessary arguments.

```python
def parse_arguments():
    parser = argparse.ArgumentParser("ArmoniK Example Client")
    parser.add_argument("-e", "--endpoint", required=True, type=str, help="Control plane endpoint")
    parser.add_argument("-p", "--partition", type=str, help="Partition used for the worker")
    parser.add_argument("-v", "--values", type=float, help="List of values to compute instead of x in [0, n[", nargs='+')
    parser.add_argument("-n", "--nfirst", type=int, help="Compute from 0 inclusive to n exclusive, n=10 by default", default=10)
    return parser.parse_args()
```

You will need to specify:
- the endpoint to connect to the Control Plane.
- to which partition (expliciter) you want your task sent
- values: sum
- nfirst: commence de 0

Pour ces deux dernières, j'aurais besoin de savoir leur utilité dans un Hello World.


## Main

Now is the time to call your Main function.

```python
def main():
    args = parse_arguments()
    print("Hello ArmoniK Python Example !")
    # Open a channel to the control plane
    with grpc.insecure_channel(args.endpoint) as channel:
        # Create a task submitting client
        client = ArmoniKSubmitter(channel)
        # Create the results client
        results_client = ArmoniKResult(channel)
        # Default task options to be used in a session
        default_task_options = TaskOptions(max_duration=timedelta(seconds=300), priority=1, max_retries=5, partition_id=args.partition)
        # Create a session
        session_id = client.create_session(default_task_options=default_task_options, partition_ids=[args.partition] if args.partition is not None else None)
        print(f"Session {session_id} has been created")
        try:
            # Create the payload
            payload = Payload([i for i in range(args.nfirst)] if args.values is None else args.values)
            # Create the result
            result_name = f"main_result_{int(datetime.now().timestamp())}"
            result_id = results_client.get_results_ids(session_id, [result_name])[result_name]
            # Define the task with the payload
            task_definition = TaskDefinition(payload.serialize(), expected_output_ids=[result_id])
            # Submit the task
            submitted_tasks, submission_errors = client.submit(session_id, [task_definition])
            for e in submission_errors:
                print(f"Submission error : {e}")

            print(f"Main tasks have been sent")

            for t in submitted_tasks:
                # Wait for the result to be available
                reply = client.wait_for_availability(session_id, result_id=t.expected_output_ids[0])
                if reply is None:
                    # This should not happen
                    print("Result unexpectedly unavailable")
                    continue
                if reply.is_available():
                    # Result is available, get the result
                    result_payload = Result.deserialize(cast(bytes, client.get_result(session_id, result_id=t.expected_output_ids[0])))
                    print(f"Result : {result_payload.value}")
                else:
                    # Result is in error
                    errors = "\n".join(reply.errors)
                    print(f'Errors : {errors}')
        except KeyboardInterrupt:
            # If we stop the script, cancel the session
            client.cancel_session(session_id)
            print("Session has been cancelled")
        finally:
            print("Good bye !")


if __name__ == "__main__":
    main()
```

Following this order, your Client should:
1. Set grpc as a channel with the Control Plane (pourquoi ouvrir un channel? argsendpoint = url)
2. Create an ArmoniK submitter Client va créer une instance appelée Client
3. Create the payload
4. Set the task options. Leave them to defaults for this example. (Explain  the defaults here?)
5. Create a session (pourquoi créer une session? A quoi ça sert?)
6. Submit the tasks with the results IDs.

As in the code above, you may add some print messages to check that every step is happening correctly. If not, we included in this example error messages to help you detect where your deployment might have failed.

Inutile : (is there a need to list all the possible errors?)

	- submission error
	- waiting for the task submission : this one should not happen as this example is fairly straightforward.
	- reply is available
	- result error (explain)
	- script is interrupted

Remember to have your Client actually say "Goodbye" so you know everything worked!

That's it! You are now ready to start with [suggest going to the next page]

