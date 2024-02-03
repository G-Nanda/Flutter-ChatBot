import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatbot/consts.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _openAI = OpenAI.instance.build(
    token: open_api_key,
    baseOption: HttpSetup(
      receiveTimeout: const Duration(seconds: 5),
      ),
      enableLog: true,
      );

      


  final ChatUser _currentUser=ChatUser(id: '1',firstName: 'Nanda',lastName: 'G');
  final ChatUser _gptChatUser=ChatUser(id: '2',firstName: 'Chat',lastName: 'Bot');

  List<ChatMessage> _messages=<ChatMessage>[];

  List<ChatUser> _typingUsers = <ChatUser>[];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      appBar: AppBar(
        backgroundColor:Colors.deepPurple[800],
        centerTitle: true,
        title: const Text(
          'Flutter ChatBot',
          
            style: TextStyle(
              
              color: Colors.white,
            ),
        ),

      ),
      body: DashChat(
        inputOptions: InputOptions(
          
        inputDecoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),hintText: "Write a Message",hintStyle: TextStyle(color: Colors.white),filled: true,fillColor: Color.fromARGB(255, 144, 91, 241))
        ),
        typingUsers: _typingUsers,
        
        currentUser: _currentUser,
        messageOptions:  MessageOptions(
          currentUserContainerColor: Colors.deepPurple[800],
          containerColor: Colors.deepPurple.shade500,
          textColor: Colors.white,
        ),
        
         onSend: 
         (ChatMessage m){
          
          getChatResponse(m);
         },
         
          messages: _messages),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async{
    setState(() {
      
     
      _typingUsers.add(_gptChatUser);
       _messages.insert(0, m);
       print(m.text);
    });

    List<Messages> _messagesHistory = _messages.reversed.map((m){
      if(m.user == _currentUser){
        return Messages(role: Role.user,content: m.text);
      }
      else {
        return Messages(role: Role.assistant,content: m.text);

      }
    }) .toList();

    final request = ChatCompleteText(
      model: GptTurbo0301ChatModel(), 
      messages: _messagesHistory,
      maxToken: 200);
  

    final response = await _openAI.onChatCompletion(request: request);

    for(var element in response!.choices){
      if(element.message != null){
        setState(() {
          _messages.insert(0, 
          ChatMessage(
            user: _gptChatUser,
             createdAt: DateTime.now(),
             text: element.message!.content),

             );
        });
      }
    }

    setState(() {

      _typingUsers.remove(_gptChatUser);
    });

  }
}