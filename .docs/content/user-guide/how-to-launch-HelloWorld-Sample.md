# How to launch HelloWorld Sample

The goal of this guide is to learn how to use ArmoniK by launching the HelloWorld Sample.

You need to git clone [ArmoniK](https://github.com/aneoconsulting/ArmoniK/tree/main) and [ArmoniK.Samples](https://github.com/aneoconsulting/ArmoniK.Samples) to follow this guide.

## Worker

Start by building your worker image from ArmoniK.Samples root repository:

```bash
docker build -f"./csharp/native/HelloWorld/Worker/Dockerfile" -t hello "./csharp/native/"
```

## Partition

Add a helloworld partition to [parameter.tfvar](https://github.com/aneoconsulting/ArmoniK/blob/main/infrastructure/quick-deploy/localhost/parameters.tfvars).

Copy the default one and change the partition name, add a tag to "latest", set the image to "hello".

See the example [here](https://github.com/aneoconsulting/ArmoniK/blob/main/.docs/content/2.guide/1.how-to/how-to-configure-partitions.md).

**Deploy** ArmoniK with `make` in `ArmoniK/infrastructure/quick-deploy/localhost`.

## Client

   You have differents and equivalent ways to run the client:

- Run the client from ArmoniK.Samples root repository using the **.Net** command line:

   ```bash
   dotnet run --endpoint "http://<ip>:5001" --partition <partition name> --project csharp/native/HelloWorld/Client
   ```

- Run the client from ArmoniK.Samples root repository using the **Docker** command line:

   ```bash
   docker build -f "./csharp/native/HelloWorld/Client/Dockerfile" -t client "./csharp/native/"
   docker run --rm --name <container name> client --endpoint "http://<ip>:5001" --partition <partition name>
   ```

- Run the client **in Visual Studio**:

   Open the .Net file in `ArmoniK.Sample/csharp/native/HelloWorld/Client/.` as a project.

   ![Debug property](./Debug-property.jpg)

   Open the Debug property and add as arguments using the command line:

   ```bash
   --endpoint "http://<ip>:5001" --partition <partition name>
   ```

   Run the project.

## Result

The console will show something like this:

```bash
sessionId: 516fbefb-27e9-4309-ba8e-0fd20634f42e
Task id: 059bbec5-bdeb-490e-970e-db90495cf935
resultId: efa249c0-aacd-449b-844d-c9abd1788f5a, data: Hello World_ efa249c0-aacd-449b-844d-c9abd1788f5a
```
