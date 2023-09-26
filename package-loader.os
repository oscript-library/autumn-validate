// Пояснения по переменным даны в конце модуля
Перем ПоказатьСообщенияЗагрузки;
Перем ВыдаватьОшибкуПриЗагрузкеУжеСуществующихКлассовМодулей;

Перем КэшМодулей;

Процедура ПриЗагрузкеБиблиотеки(Путь, СтандартнаяОбработка, Отказ)
	Вывести("
	|ПриЗагрузкеБиблиотеки " + Путь);	

	Если Осень <> Неопределено Тогда
		ИмяБиблиотеки = Новый Файл(ТекущийСценарий().Каталог).Имя;
		
		ИмяЗаготовки = "Инициализация_" + ИмяБиблиотеки;
		ИмяКлассаЗаготовки = СтрЗаменить(ИмяЗаготовки, "-", "_");
		
		ПутьДоЗаготовки = ОбъединитьПути(Путь, "src/Заготовки/" + ИмяЗаготовки + ".os");
		
		ПодключитьСценарий(ПутьДоЗаготовки, ИмяКлассаЗаготовки);
		Осень.ДобавитьЗаготовкуДляАвтоИнициализации(ИмяКлассаЗаготовки);

		мКаталог = ОбъединитьПути(Путь, "src/Классы");
		ОбработатьКаталогКлассов(мКаталог, СтандартнаяОбработка, Отказ);
	Иначе
		ВызватьИсключение "Некорректный порядок импорта библиотек. Сначала подключите autumn";	
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработатьКаталогКлассов(Знач Путь, СтандартнаяОбработка, Отказ)

	КаталогКлассов = Новый Файл(Путь);
	
	Если КаталогКлассов.Существует() Тогда
		Файлы = НайтиФайлы(КаталогКлассов.ПолноеИмя, "*.os");
		Для Каждого Файл Из Файлы Цикл
			Вывести(СтрШаблон("	класс (по соглашению) %1, файл %2", Файл.ИмяБезРасширения, Файл.ПолноеИмя));
			СтандартнаяОбработка = Ложь;
			// ДобавитьКласс(Файл.ПолноеИмя, Файл.ИмяБезРасширения);
			ДобавитьКлассЕслиРанееНеДобавляли(Файл.ПолноеИмя, Файл.ИмяБезРасширения);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

Процедура ДобавитьКлассЕслиРанееНеДобавляли(ПутьФайла, ИмяКласса)
	Вывести("Добавляю класс, если ранее не добавляли " + ИмяКласса);
	Если ВыдаватьОшибкуПриЗагрузкеУжеСуществующихКлассовМодулей Тогда
		Вывести("Добавляю класс " + ИмяКласса);
		ДобавитьКласс(ПутьФайла, ИмяКласса);
		Возврат;
	КонецЕсли;
	
	КлассУжеЕсть = Ложь;
	Попытка
		Объект = Новый(ИмяКласса);
		КлассУжеЕсть = Истина;
	Исключение
		СообщениеОшибки = ОписаниеОшибки();
		ИскомаяОшибка = СтрШаблон("Конструктор не найден (%1)", ИмяКласса);
		КлассУжеЕсть = СтрНайти(СообщениеОшибки, ИскомаяОшибка) = 0;
	КонецПопытки;
	Если Не КлассУжеЕсть Тогда
		
		Вывести("Добавляю класс, т.к. он не найден - " + ИмяКласса);
		ДобавитьКласс(ПутьФайла, ИмяКласса);
	
	Иначе
		Вывести("Пропускаю загрузку класса " + ИмяКласса);

	КонецЕсли;
КонецПроцедуры

Процедура Вывести(Знач Сообщение)
	Если ПоказатьСообщенияЗагрузки Тогда
		Сообщить(Сообщение);
	КонецЕсли;
КонецПроцедуры

Функция ПолучитьБулевоИзПеременнойСреды(Знач ИмяПеременнойСреды, Знач ЗначениеПоУмолчанию)
	Рез = ЗначениеПоУмолчанию;
	РезИзСреды = ПолучитьПеременнуюСреды(ИмяПеременнойСреды);
	Если ЗначениеЗаполнено(РезИзСреды) Тогда
		РезИзСреды = СокрЛП(РезИзСреды);
		Попытка
			Рез = Число(РезИзСреды) <> 0 ;
		Исключение
			Рез = ЗначениеПоУмолчанию;
			Сообщить(СтрШаблон("Неверный формат переменной среды %1. Ожидали 1 или 0, а получили %2", ИмяПеременнойСреды, РезИзСреды));
		КонецПопытки;
	КонецЕсли;

	Возврат Рез;
КонецФункции

// Если Истина, то выдаются подробные сообщения о порядке загрузке пакетов, классов, модулей, что помогает при анализе проблем
// очень полезно при анализе ошибок загрузки
// Переменная среды может принимать значение 0 (выключено) или 1 (включено)
// Значение флага по умолчанию - Ложь
ПоказатьСообщенияЗагрузки = ПолучитьБулевоИзПеременнойСреды(
		"OSLIB_LOADER_TRACE", Ложь);
			
// Если Ложь, то пропускаются ошибки повторной загрузки классов/модулей, 
//что важно при разработке/тестировании стандартных библиотек
// Если Истина, то выдается ошибка при повторной загрузке классов библиотек из движка
// Переменная среды может принимать значение 0 (выключено) или 1 (включено)
// Значение флага по умолчанию - Истина
ВыдаватьОшибкуПриЗагрузкеУжеСуществующихКлассовМодулей = ПолучитьБулевоИзПеременнойСреды(
	"OSLIB_LOADER_DUPLICATES", Ложь);

// для установки других значений переменных среды и запуска скриптов можно юзать следующую командную строку
// (set OSLIB_LOADER_TRACE=1) && (oscript .\tasks\test.os)

КэшМодулей = Новый Массив;
