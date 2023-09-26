#Использовать decorator

Перем _Валидатор;

Функция ОбработатьЖелудь(Желудь, ОпределениеЖелудя) Экспорт // BSLLS:UnusedParameters-off
	
	ПостроительДекоратора = Новый ПостроительДекоратора(Желудь);
	
	Поле = Новый Поле("__ОсеннийВалидатор")
		.ЗначениеПоУмолчанию(_Валидатор);
	
	ПостроительДекоратора.Поле(Поле);
	
	ЕстьПодходящиеМетоды = ОбработатьАннотациюНаМетодах(ОпределениеЖелудя, ПостроительДекоратора);
	ЕстьПодходящиеМетоды = ОбработатьАннотациюНаПараметрахМетодов(ОпределениеЖелудя, ПостроительДекоратора) 
		ИЛИ ЕстьПодходящиеМетоды;

	Если НЕ ЕстьПодходящиеМетоды Тогда
		Возврат Желудь;
	КонецЕсли;
		
	Возврат ПостроительДекоратора.Построить();
	
КонецФункции

Функция ОбработатьАннотациюНаМетодах(ОпределениеЖелудя, ПостроительДекоратора)

	Методы = ОпределениеЖелудя.НайтиМетодыСАннотациями("Валидно");
	
	Если Методы.Количество() = 0 Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Для Каждого Метод Из Методы Цикл
		
		ТелоПерехватчика = "
		|__РезультатВалидации = __ОсеннийВалидатор.Валидировать(Декоратор_ВозвращаемоеИзМетодаЗначение);
		|__ОписаниеОшибокВалидации = __ОсеннийВалидатор.ОписаниеОшибокВалидации(__РезультатВалидации);
		|Если ЗначениеЗаполнено(__ОписаниеОшибокВалидации) Тогда
		|	__ТекстИсключения = СтрШаблон(
		|		""Возвращаемое значение метода %1 в желуде %2 не прошло валидацию:"",
		|		""" + Метод.Имя + """,
		|		""" + ОпределениеЖелудя.Имя() + """
		|	);
		|	__ТекстИсключения = __ТекстИсключения + Символы.ПС + __ОписаниеОшибокВалидации;
		|	
		|	ВызватьИсключение __ТекстИсключения;
		|КонецЕсли;
		|";

		Перехватчик = Новый Перехватчик(Метод.Имя)
			.ТипПерехватчика(ТипыПерехватчиковМетода.После)
			.Тело(ТелоПерехватчика);
		
		ПостроительДекоратора.Перехватчик(Перехватчик);
		
	КонецЦикла;

	Возврат Истина;

КонецФункции

Функция ОбработатьАннотациюНаПараметрахМетодов(ОпределениеЖелудя, ПостроительДекоратора)

	ЕстьПодходящиеМетоды = Ложь;
	Сообщить("Обработка аннотации Валидно на параметрах методов желудя " + ОпределениеЖелудя.Имя() + "...");

	Для Каждого Метод Из ОпределениеЖелудя.Методы() Цикл
		Сообщить("Обработка метода " + Метод.Имя + "...");
		ИменаПроверяемыхПараметров = Новый Массив;

		Для Каждого ПараметрМетода Из Метод.Параметры Цикл
			Сообщить("Обработка параметра " + ПараметрМетода.Имя + "...");
			АннотацияВалидно = РаботаСАннотациями.НайтиАннотацию(ПараметрМетода.Аннотации, "Валидно");
			
			Если АннотацияВалидно = Неопределено Тогда
				Сообщить("Параметр " + ПараметрМетода.Имя + " не содержит аннотацию Валидно");
				Продолжить;
			КонецЕсли;

			ИменаПроверяемыхПараметров.Добавить(ПараметрМетода.Имя);

		КонецЦикла;

		Если ИменаПроверяемыхПараметров.Количество() = 0 Тогда
			Продолжить;
		КонецЕсли;

		ЕстьПодходящиеМетоды = Истина;
		ТелоПерехватчика = "";

		Для Каждого ИмяПроверяемогоПараметра Из ИменаПроверяемыхПараметров Цикл
			ШаблонТелаПерехватчика = "
			|__РезультатВалидации = __ОсеннийВалидатор.Валидировать(" + ИмяПроверяемогоПараметра + ");
			|__ОписаниеОшибокВалидации = __ОсеннийВалидатор.ОписаниеОшибокВалидации(__РезультатВалидации);
			|Если ЗначениеЗаполнено(__ОписаниеОшибокВалидации) Тогда
			|	__ТекстИсключения = СтрШаблон(
			|		""Параметр %1 метода %2 в желуде %3 не прошел валидацию:"",
			|		""" + ИмяПроверяемогоПараметра + """,
			|		""" + Метод.Имя + """,
			|		""" + ОпределениеЖелудя.Имя() + """
			|	);
			|	__ТекстИсключения = __ТекстИсключения + Символы.ПС + __ОписаниеОшибокВалидации;
			|	
			|	ВызватьИсключение __ТекстИсключения;
			|КонецЕсли;
			|";

			ТелоПерехватчика = ТелоПерехватчика + ШаблонТелаПерехватчика + Символы.ПС;
		КонецЦикла;

		Перехватчик = Новый Перехватчик(Метод.Имя)
			.ТипПерехватчика(ТипыПерехватчиковМетода.Перед)
			.Тело(ТелоПерехватчика);

		ПостроительДекоратора.Перехватчик(Перехватчик);

	КонецЦикла;

	Возврат ЕстьПодходящиеМетоды;

КонецФункции

&Напильник
Процедура ПриСозданииОбъекта(&Пластилин Валидатор)
	_Валидатор = Валидатор;
КонецПроцедуры
