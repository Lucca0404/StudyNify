# StudyNify

StudyNotify é um aplicativo Flutter para Android que reúne atividades acadêmicas, com disciplina, prazo e detalhes de cada entrega. O projeto usa o Firebase Cloud Messaging (FCM) para demonstrar notificações simples, notificações com imagem e abertura dos detalhes de uma atividade pelo toque no aviso.

## Como rodar

Você precisa do Flutter SDK, do Android Studio com o Android SDK e de um aparelho Android ou emulador com Google Play Services. Também precisa ter acesso a um projeto no Firebase. O plano gratuito Spark é suficiente para os testes de FCM.

1. Clone o repositório e abra a pasta que contém o `pubspec.yaml`.
2. Instale as dependências com `flutter pub get`.
3. Se precisar configurar seu próprio projeto Firebase, instale a [Firebase CLI](https://firebase.google.com/docs/cli) e execute os comandos abaixo na raiz do repositório. Selecione seu projeto Firebase e a plataforma Android. Use o `applicationId` do projeto ao registrar o app. O FlutterFire gera o arquivo `lib/firebase_options.dart`, que o app usa na inicialização.

   ```bash
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure --platforms=android
   ```

4. Inicie o emulador ou conecte o aparelho. Execute `flutter run` e permita as notificações quando o Android solicitar.

## Como demonstrar as notificações

Com o app rodando em modo de depuração, copie o valor exibido depois de `TOKEN FCM:` no terminal do Flutter ou na aba **Run** do Android Studio. No projeto correspondente do [Firebase Console](https://console.firebase.google.com/), abra **Messaging**, crie uma notificação e use **Enviar mensagem de teste** com esse token. Antes de clicar em **Testar**, pressione **Home** no Android para deixar o StudyNotify em segundo plano.

| Teste | Configuração no Firebase Console | Resultado esperado |
| --- | --- | --- |
| Push simples | Título **Lembrete do StudyNotify** e mensagem **O prazo do Trabalho de Flutter está chegando.** | O Android exibe o título e a mensagem. |
| Push com imagem | Título **Material do Trabalho de Flutter**, mensagem **Confira a imagem de apoio para a próxima entrega.** e uma URL HTTPS pública que abra diretamente um JPG ou PNG no campo de imagem. | A imagem aparece ao expandir o aviso. |
| Abertura dos detalhes | Título **Trabalho de Flutter**, mensagem **Toque para abrir os detalhes da entrega.** e, em **Opções adicionais → Dados personalizados**, chave `atividade_id` com valor `1`. | Tocar no aviso abre diretamente os detalhes de **Trabalho de Flutter**. |

Para demonstrar a navegação nas duas situações, envie o terceiro push com o app em segundo plano e depois repita com o app removido da lista de recentes. O código trata os dois casos com `onMessageOpenedApp` e `getInitialMessage()`, respectivamente.

As atividades de demonstração ficam em `lib/main.dart`. A chave `atividade_id` aceita os seguintes IDs.

| ID | Atividade |
| --- | --- |
| `1` | Trabalho de Flutter |
| `2` | Lista de Algoritmos |
| `3` | Estudar para a prova |

## Tecnologias

- Flutter e Dart
- Firebase Core (`firebase_core`)
- Firebase Cloud Messaging (`firebase_messaging`)

## Documentação

- [Configurar o Firebase no Flutter](https://firebase.google.com/docs/flutter/setup)
- [Enviar uma notificação de teste](https://firebase.google.com/docs/cloud-messaging/flutter/get-started)
- [Receber mensagens e tratar o toque na notificação](https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages)