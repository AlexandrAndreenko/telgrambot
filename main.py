import telebot
bot = telebot.TeleBot('1590866256:AAGY74EF1Gb00XiBXWkVy-DNupnVN46nGE0')

import r
import random
from telebot import types
from r import q1,q2,q3,q4,q5,q6,q7,q8,q9,q10,q11,q12,q13,q14,q15,q16,q17,q18,q19,q20,q21,q22,q23,q24,q25,q26,q27,q28,q29,q30,q31,q32,q33,q34,q35,q36,q37,q38,q39,q40,q41,q42,q43,q44,q45,q46,q47,q48,q49,q50,\
q51,q52,q53,q54,q55,q56,q57,q58,q59,q60,q61,q62,q63,q64,q65,q66,q67,q68,q69,q70,q71,q72,q73,q74,q75,q76,q77,q78,q79,q80,q81,q82,q83,q84,q85,q86,q87,q88,q89,q90,q91,q92,q93,q94,q95,q96,q97,q98,q99,q100,q101

random_message = lambda: random.choice(Oracle + e)


Oracle = [q1,q2,q3,q4,q5,q6,q7,q8,q9,q10,
             q11,q12,q13,q14,q15,q16,q17,q18,q19,q20,
             q21,q22,q23,q24,q25,q26,q27,q28,q29,q30,
             q31,q32,q33,q34,q35,q36,q37,q38,q39,q40,
             q41,q42,q43,q44,q45,q46,q47,q48,q49,q50,
             q51,q52,q53,q54,q55,q56,q57,q58,q59,q60,
             q61,q62,q63,q64,q65,q66,q67,q68,q69,q70,
             q71,q72,q73,q74,q75,q76,q77,q78,q79,q80,
             q81,q82,q83,q84,q85,q86,q87,q88,q89,q90,
             q91,q92,q93,q94,q95,q96,q97,q98,q99,q100,
             q101]
e = q101



@bot.message_handler(commands=['start'])
def start_message(message):
    bot.send_message(message.chat.id, 'Привет, какой знак зодиака интересует?')




@bot.message_handler(content_types=['text'])
def get_text_messages(message): 
	if message.text == "Овен" or message.text == 'овен': 
		bot.send_message(message.from_user.id, "Овен - " + random_message())
	
	if message.text == "Телец" or message.text == 'телец': 
		bot.send_message(message.from_user.id, "Телец - " + random_message())
	
	if message.text == "Близнецы" or message.text == 'близнецы': 
		bot.send_message(message.from_user.id, "Близнецы - " + random_message())
	
	if message.text == "Рак" or message.text == 'рак': 
		bot.send_message(message.from_user.id, "Рак - " + random_message())
	
	if message.text == "Лев" or message.text == 'лев': 
		bot.send_message(message.from_user.id, "Лев - " + random_message())

	if message.text == "Дева" or message.text == 'дева': 
		bot.send_message(message.from_user.id, "Дева - " + random_message())
	
	if message.text == "Весы" or message.text == 'весы': 
		bot.send_message(message.from_user.id, "Весы - " + random_message())
	
	if message.text == "Скорпион" or message.text == 'скорпион': 
		bot.send_message(message.from_user.id, "Скорпион - " + random_message())
	
	if message.text == "Стрелец" or message.text == 'стрелец': 
		bot.send_message(message.from_user.id, "Стрелец - " + random_message())
	
	if message.text == "Козерог" or message.text == 'козерог': 
		bot.send_message(message.from_user.id, "Козерог - " + random_message())

	if message.text == "Водолей" or message.text == 'водолей': 
		bot.send_message(message.from_user.id, "Водолей - " + random_message())
	
	if message.text == "Рыбы" or message.text == 'рыбы'or message.text == 'рыба' or message.text == 'Рыба' : 
		bot.send_message(message.from_user.id, "Рыбы - " + random_message())

	if message.text == "Рыбка" or message.text == 'рыбка': 
		bot.send_message(message.from_user.id, "Ты особенная - " + random_message())

	if message.text == "Стас" or message.text == 'стас': 
		bot.send_message(message.from_user.id, "Иди на хуй")
	else :
		return

bot.polling(none_stop=True, interval=2, timeout=99999)






