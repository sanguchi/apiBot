import telehx.TeleHxBot;
import telehx.TeleHxTypes;
import dotenv.Dotenv;
using telehx.TeleHxMethods;

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
    bot = new TeleHxBot(token);
    trace('bot started');
    new BotHandler(bot);
    bot.getMe(function(user: HxUser){
      trace('Bot id: ${user.id}, username: @${user.username}');
    });
    trace("Sending message...");
    bot.sendMessage({chat_id: owner, text: "Bot started."}, function(message: HxMessage){
      trace('Message ${message.message_id} sent!');
    });
    trace('Entering idle mode.');
    bot.startPolling();
  }

  static function main() {
        new Main();
    }
}
