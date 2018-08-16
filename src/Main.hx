import telehx.TeleHxBot;
import telehx.TeleHxTypes;
import dotenv.Dotenv;
using telehx.TeleHxMethods;

#if neko
import neko.Web;
#end

class Main {
  var token: String;
  var owner: String;
  var bot: TeleHxBot;
  public function new() {
		// Create bot instance once.
    Dotenv.feedFiles(['.env']);
    this.token = Dotenv.get('TOKEN', '');
    this.owner = Dotenv.get('OWNER', '');
    if(this.token == '' || this.owner == '') {
      trace("Token or Owner not set, please fix.");
      return;
    }
    bot = new TeleHxBot(token);
    trace('bot started');
    new BotHandler(bot);
		
	// Neko code handled by neko server or apache mod.
	#if (neko && server)
	
	// We received our first request, set the function to just parse the update.
	trace('mod_neko: ${Web.isModNeko} - mod_tora: ${Web.isTora}');
	if(Web.isModNeko || Web.isTora){
		trace("Setting up entry point");
		handleUpdate();
		Web.cacheModule(handleUpdate);
	
	// This code get called only when executing the script alone.
	} else {
		bot.getMe(function(user: HxUser){
      trace('Bot id: ${user.id}, username: @${user.username}');
    });
    trace("Sending message...");
    bot.sendMessage({chat_id: owner, text: "Bot started."}, function(message: HxMessage){
      trace('Message ${message.message_id} sent!');
    });
		trace("Setting webhook");
		bot.setWebhook({url: Dotenv.get('WEBHOOK_URL', '')});
	}
	
	// Code called when compiled as non-neko target.
	#else
    trace('Entering idle mode.');
		bot.deleteWebhook();
    bot.startPolling();
	#end
  }

  static function main() {
      new Main();
    }
	#if (neko && server)
		public function handleUpdate(): Void {
			var update: HxUpdate = haxe.Json.parse(Web.getPostData());
			bot.notifyPlugins(update);
		}
	#end
}
