
import 'package:flutter/material.dart';
import 'telas/telas_jogo.dart';

void main() {
  runApp(const FlagGameApp());
}

const Color fundo = Color(0xFF101426);
const Color cartao = Color(0xFF1C2440);
const Color roxo = Color(0xFF8875FF);
const Color verde = Color(0xFF45D6AD);

class FlagGameApp extends StatelessWidget {
  const FlagGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flag Game',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: fundo,
        colorScheme: ColorScheme.fromSeed(
          seedColor: roxo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MenuInicial(),
    );
  }
}

class MenuInicial extends StatefulWidget {
  const MenuInicial({super.key});

  @override
  State<MenuInicial> createState() => _MenuInicialState();
}

class _MenuInicialState extends State<MenuInicial> {
  String continente = 'Mundo inteiro';
  int tempo = 60;
  String dificuldade = 'Médio';

 final List<Map<String, dynamic>> continentes = [
  {'nome': 'Mundo', 'icone': Icons.public},
  {'nome': 'África', 'icone': Icons.public},
  {'nome': 'América', 'icone': Icons.travel_explore},
  {'nome': 'Ásia', 'icone': Icons.language},
  {'nome': 'Europa', 'icone': Icons.account_balance},
  {'nome': 'Oceania', 'icone': Icons.waves},
];

  void iniciarJogo({bool aleatorio = false}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => TelaJogo(
        continente: aleatorio ? 'Mundo inteiro' : continente,
        tempo: tempo,
        dificuldade: dificuldade,
      ),
    ),
  );
}
  void configurarContinente() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cartao,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Escolha seu continente',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Desafie seus conhecimentos geográficos.',
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 20),
              ...continentes.map((item) {
                final nome = item['nome'] as String;
                final selecionado = continente == nome;

                return ListTile(
                  leading: Icon(
                    item['icone'] as IconData,
                    color: roxo,
                  ),
                  title: Text(nome),
                  trailing: selecionado
                      ? const Icon(
                          Icons.check_circle,
                          color: verde,
                        )
                      : null,
                 onTap: () {
                setState(() => continente = nome);

              Navigator.pop(context);

              WidgetsBinding.instance.addPostFrameCallback((_) {
              iniciarJogo();
          });
        },
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void configurarTempo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cartao,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        final opcoes = [30, 60, 180, 300];

       
return Padding(
  padding: const EdgeInsets.all(24),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Tempo de partida',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),

      RadioGroup<int>(
        groupValue: tempo,
        onChanged: (valor) {
          if (valor != null) {
            setState(() => tempo = valor);
            Navigator.pop(context);
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: opcoes.map((segundos) {
            final texto = segundos < 60
                ? '$segundos segundos'
                : '${segundos ~/ 60} minuto(s)';

            return RadioListTile<int>(
              value: segundos,
              activeColor: roxo,
              title: Text(texto),
            );
          }).toList(),
        ),
      ),

      const SizedBox(height: 12),
    ],
  ),
);

      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: roxo.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      color: roxo,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FLAG GAME',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'Explore o mundo!',
                        style: TextStyle(color: Colors.white60),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: configurarTempo,
                    icon: const Icon(Icons.timer_outlined),
                    tooltip: 'Configurar tempo',
                  ),
                ],
              ),

              const SizedBox(height: 36),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF5145B8),
                      Color(0xFF282D61),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🌎  DESAFIO GEOGRÁFICO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Você conhece\nas bandeiras\ndo mundo?',
                      style: TextStyle(
                        fontSize: 31,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Teste seus conhecimentos e descubra '
                      'quantos países você consegue reconhecer.',
                      style: TextStyle(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        const Icon(
                          Icons.bolt,
                          color: Color(0xFFFFD166),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Tempo: ${tempo}s',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Como deseja jogar?',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Escolha um modo para começar.',
                style: TextStyle(color: Colors.white60),
              ),

              const SizedBox(height: 20),

              _opcaoJogo(
                icone: Icons.public,
                titulo: 'Jogo aleatório',
                descricao: 'Bandeiras do mundo inteiro',
                cor: verde,
                onTap: () => iniciarJogo(aleatorio: true),
              ),

              const SizedBox(height: 14),

              _opcaoJogo(
                icone: Icons.travel_explore,
                titulo: 'Jogar por continente',
                descricao: 'Escolha uma região do planeta',
                cor: roxo,
                onTap: configurarContinente,
              ),

              const SizedBox(height: 24),

              const Text(
                'Nível de dificuldade',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Escolha como quer desafiar seus conhecimentos.',
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['Fácil', 'Médio', 'Difícil'].map((nivel) {
                  final selecionado = dificuldade == nivel;
                  return ChoiceChip(
                    label: Text(nivel),
                    selected: selecionado,
                    onSelected: (_) => setState(() => dificuldade = nivel),
                    selectedColor: roxo,
                    labelStyle: TextStyle(
                      color: selecionado ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cartao,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: Color(0xFFFFD166),
                      size: 30,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Duração da partida',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tempo < 60
                                ? '$tempo segundos'
                                : '${tempo ~/ 60} minuto(s)',
                            style: const TextStyle(
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: configurarTempo,
                      child: const Text('Alterar'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Center(
                child: Text(
                  'APRENDA • EXPLORE • DIVIRTA-SE',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _opcaoJogo({
    required IconData icone,
    required String titulo,
    required String descricao,
    required Color cor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: cartao,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icone, color: cor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      descricao,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TelaPreparacao extends StatelessWidget {
  final String continente;
  final int tempo;

  const TelaPreparacao({
    super.key,
    required this.continente,
    required this.tempo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preparar partida'),
        backgroundColor: fundo,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.flag_circle,
                size: 90,
                color: roxo,
              ),
              const SizedBox(height: 24),
              const Text(
                'Tudo pronto?',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text('Modo: $continente'),
              const SizedBox(height: 8),
              Text('Tempo: $tempo segundos'),
              const SizedBox(height: 28),
              const Text(
                'Esta é a tela de preparação. '
                'Na próxima etapa, vamos implementar '
                'as perguntas, as bandeiras e o cronômetro.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar ao menu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
