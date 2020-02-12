import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

final EthereumAddress contractAddr =
    EthereumAddress.fromHex('0xf2f962D9D61E7F245444B34fe1db98eC74Ed3e37');
const String privateKey =
    "13fa1ca71e571080b93b49b874f380e6fcea26dfda8cfdab8ee270f28e6f7646";
String abiCode;
DeployedContract contract;
ContractFunction taskCount, createTask, tasks, toggleCompleted;
Credentials credentials;
const String apiUrl = "http://192.168.43.191:7545";
const String wsUrl = "ws://192.168.43.191:7545";
Web3Client client;

class EthereumC {
  BuildContext context;
  EthereumC(BuildContext context) {
    this.context = context;
  }

  main() async {
    client = Web3Client(apiUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    abiCode = await DefaultAssetBundle.of(context).loadString('assets/abi.json');
    contract = DeployedContract(
        ContractAbi.fromJson(abiCode, 'TodoList'), contractAddr);
    credentials = await client.credentialsFromPrivateKey(privateKey);
    taskCount = contract.function('taskCount');
    createTask = contract.function('createTask');
    toggleCompleted = contract.function('toggleCompleted');
    tasks = contract.function('tasks');
  }

  fetchAllTasks() async {
    await main();
    List allTasks = List();
    BigInt taskId = await _getTaskId(contract, taskCount);
    for (int i = 1; i <= taskId.toInt(); i++) {
      var task = await client
          .call(contract: contract, function: tasks, params: [BigInt.from(i)]);
      print(task);
      if (task != null) allTasks.add(task);
    }
    return allTasks;
  }

  _getTaskId(DeployedContract ctr, ContractFunction fnc) async {
    var response = await client.call(
      contract: ctr,
      function: fnc,
      params: [],
    );
    return response.first as BigInt;
  }

  createTasks(String task) async {
    await client.sendTransaction(
        credentials,
        Transaction.callContract(
            contract: contract, function: createTask, parameters: [task]));
  }

  taskCompleted(int _id) async {
    await client.sendTransaction(
        credentials,
        Transaction.callContract(
            contract: contract,
            function: toggleCompleted,
            parameters: [BigInt.from(_id + 1)]));
  }
}
