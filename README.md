
# Flag Game — Desafio das Bandeiras

Aplicativo Flutter para testar conhecimentos sobre bandeiras de países, com partidas por continente ou em modo aleatório.

## Funcionalidades
- Modo por continente: África, América, Ásia, Europa e Oceania.
- Modo aleatório com **195 países**.
- Quatro alternativas por pergunta.
- Cronômetro configurável: 30 segundos, 60 segundos, 3 minutos ou 5 minutos.
- Feedback visual de acerto/erro e pontuação durante a partida.
- Tela final com perguntas respondidas, acertos e percentual de acertos.
- Recorde salvo localmente com `shared_preferences`.

## Requisitos
- Flutter SDK compatível com o SDK definido em `pubspec.yaml`.
- Android Studio ou VS Code com as extensões Flutter e Dart.

## Como executar
1. Instale o Flutter e configure um emulador ou conecte um dispositivo.
2. Abra a pasta do projeto no terminal.
3. Execute:
   ```bash
   flutter pub get
   flutter run
   ```

## Recursos utilizados
- Flutter e Dart.
- Widgets Material (`Scaffold`, `Text`, botões, ícones e componentes de interface).
- `Navigator` para navegação entre telas.
- `setState` para gerenciamento de estado.
- `Timer` para controlar o tempo da partida.
- `shared_preferences` para armazenar recordes localmente.
- Emojis de bandeiras e lista local de países organizada por continente.

## Observações para a entrega
O código-fonte deve ser enviado ao GitHub. A atividade também solicita um vídeo explicativo do funcionamento; esse vídeo precisa ser gravado e anexado/publicado separadamente.


## Banco de dados de bandeiras

Os dados dos países ficam no arquivo local `assets/paises.json`, carregado pelo Flutter por meio de `rootBundle`. O arquivo contém nome, continente, URL da imagem da bandeira e emoji de fallback para cada país. As imagens são fornecidas pelo [FlagCDN](https://flagcdn.com/); é necessária conexão com a internet para carregar as imagens, mas o emoji é exibido caso a imagem não carregue.
=======
