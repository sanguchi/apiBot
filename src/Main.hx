import telehx.TeleHxBot;
import dotenv.Dotenv;

class Main {
  var token: String;
  var owner: String;
  var bot: TeleHxBot;
  public function new() {
    Dotenv.feedFiles(['.env']);
    this.token = Dotenv.get('TOKEN', '');
    this.owner = Dotenv.get('OWNER', '');
    if(this.token == '' && this.owner == '') {
      trace("Token or Owner not set, please fix.");
      return;
    }
    trace("Works!");
    trace('Token: $token \nOwner: $owner');
    bot = new TeleHxBot(token);
    trace('bot started');
    bot.getMe(function(user: HxUser){
      trace('Bot id: ${user.id}, username: @${user.username}');
    });
    trace("Sending message...");
    bot.sendMessage({chat_id: owner, text: "Bot started."}, function(message: HxMessage){
      trace('Message ${message.message_id} sent!');
    });
    bot.addHandler(function(update: HxUpdate): Bool {
      switch update {
        case {inline_query: {query: query}} if(): {
          trace('Echoing message [${text}]');
          bot.sendMessage({chat_id: update.message.chat.id, text: text});
          return false;
        }
        case _ : {
          return true;
        }
      }
    });
    trace('Entering idle mode.');
    bot.startPolling();
  }

  static function main() {
        new Main();
    }
}
