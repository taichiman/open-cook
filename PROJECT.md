### БлогоДвижок OpenCook

Движок (CMS) предназначается для ведения кулинарного блога жены и личного блога по программированию

Предварительное имя релиза: OpenCook или Kitchen's Blog

#### Устройство

1) Страницы, Посты (Page, Post) - основные модели для публикаций.

Работают как дереов nested set.

Обладают несколькими способами выборки из базы:

* по id
* по short_id - /pt10978 (префикс [pt - посты, p - страницы] + случайное целое)
* по slug - /programmirovanie-na-ruby
* по friendly_id - /pt10978+programmirovanie-na-ruby (short_id + slug)

За способы выборки отвечает концерн TheFriendlyId

2) Посты - они обеспечивают публикации различных типов - Видео, Рецепты, Интервью, Статьи

Чем является пост зависит от того, к какому хабу он принадлежит.

Рецептами являются посты, которые преданлежат хабу со @hub.slug == 'recipes'

Видео являются посты, которые преданлежат хабу со @hub.slug == 'videos'

Ну и так далее.

Такая схема выбрана для того, что бы публикации различных типов можно было выводть в одной блого-ленте.

Кроме того, по сути типы публикаций, кроме как хабом - ничем не отличаются.

3) Хабы - основное (nested set) средство каталогизации любых типов публикаций (да и вообще всего).

С каталигизируемыми объектами связаны через has_many. Сейчас связаны только с постами и страницами.

Хаб является узлом для тех объектов, тип которых задан в pubs_type

Например хаб с pubs_type == 'pages', является узлом для страниц.

Настоятельно рекомендуется, что бы все хабы одного поддерева имели один и тот же pubs_type.

4) Пользователи - обеспечиваются гемом Sorcery. Он достаточно прост. Кроме того нелюблю Devise.

5) Ролевая система обеспечивается моим гемом TheRole

6) Загрузка файлов выполняется через гем TheStorage. Основан на Paperclip.

Всякий объект может быть хранилищем. Например, файлы можно прикреплять к любому созданному посту.

Картинки любого размера должны ставится на пост-обработку, пережиматься и подписыватья водяными знаками (если надо).

Должен быть функционал обрезки картинок через JCrop для формирования красивого превью Постов.

Поворот картинок тоже предусмотрен.

7) Комментарии с предмодерацией. Гем TheComments. Нужно написать тесты и отладить кеш-счетчики. Они явно работают не правильно.

8) TheAudit - очень простой модуль собирающий IP, UserAgent и прочее из каждого запроса. Надо доделать.

Итого:

Пользователи + Роли + Каталогизация + Посты и Страницы + Комментарии + Загрузка файлов + Логирование входящих запроов.