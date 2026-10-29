
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color fundoJogo = Color(0xFF101426);
const Color cartaoJogo = Color(0xFF1C2440);
const Color roxoJogo = Color(0xFF8875FF);
const Color verdeJogo = Color(0xFF45D6AD);
const Color vermelhoJogo = Color(0xFFFF647C);

class Pais {
  final String nome;
  final String bandeira;
  final String continente;
  final String emoji;

  const Pais({
    required this.nome,
    required this.bandeira,
    required this.continente,
    required this.emoji,
  });

  factory Pais.fromJson(Map<String, dynamic> json) {
    return Pais(
      nome: json['nome'] as String,
      bandeira: json['bandeira'] as String,
      continente: json['continente'] as String,
      emoji: json['emoji'] as String? ?? '🏳️',
    );
  }
}

class TelaJogo extends StatefulWidget {
  final String continente;
  final int tempo;
  final String dificuldade;

  const TelaJogo({
    super.key,
    required this.continente,
    required this.tempo,
    required this.dificuldade,
  });

  @override
  State<TelaJogo> createState() => _TelaJogoState();
}

class _TelaJogoState extends State<TelaJogo> {
  final Random _random = Random();
  
  bool _carregando = true;
  String? _erroCarregamento;
  String? _ultimoPaisNome;
  late List<Pais> _bancoDePaises;
  late List<Pais> _paisesDisponiveis;
  late List<Pais> _paisesRestantes;
  late Pais _paisAtual;
  late List<Pais> _alternativas;

  late int _tempoRestante;
  Timer? _cronometro;
  Timer? _transicao;

  int _acertos = 0;
  int _respondidas = 0;
  int _pontos = 0;

  bool _respondida = false;
  bool? _acertou;
  String? _respostaEscolhida;

  @override
  void initState() {
    super.initState();

    _tempoRestante = widget.tempo;
    _carregarBancoDePaises();
  }

  
Future<void> _carregarBancoDePaises() async {
  try {
    final conteudo = await rootBundle.loadString('assets/paises.json');
    final List<dynamic> dados = jsonDecode(conteudo) as List<dynamic>;
    _bancoDePaises = dados
        .map((item) => Pais.fromJson(item as Map<String, dynamic>))
        .toList();

    final paisesDoContinente =
        widget.continente == 'Mundo' || widget.continente == 'Mundo inteiro'
            ? List<Pais>.from(_bancoDePaises)
            : _bancoDePaises
                .where((p) => p.continente == widget.continente)
                .toList();

    const paisesFaceis = {
      'África do Sul', 'Angola', 'Argélia', 'Egito', 'Marrocos', 'Nigéria',
      'Quênia', 'Brasil', 'Argentina', 'Canadá', 'Chile', 'Colômbia',
      'Estados Unidos', 'México', 'Peru', 'Venezuela', 'China',
      'Coreia do Sul', 'Índia', 'Japão', 'Tailândia', 'Turquia', 'Alemanha',
      'Espanha', 'França', 'Itália', 'Portugal', 'Reino Unido', 'Rússia',
      'Austrália', 'Nova Zelândia',
    };
    _paisesDisponiveis = widget.dificuldade == 'Fácil'
        ? paisesDoContinente.where((p) => paisesFaceis.contains(p.nome)).toList()
        : paisesDoContinente;
    if (_paisesDisponiveis.length < 4) {
      _paisesDisponiveis = paisesDoContinente;
    }
    _paisesRestantes = List<Pais>.from(_paisesDisponiveis);
    _novaPergunta();
    if (!mounted) return;
    setState(() => _carregando = false);
    _iniciarCronometro();
  } catch (erro) {
    if (!mounted) return;
    setState(() {
      _carregando = false;
      _erroCarregamento = 'Não foi possível carregar a lista de países.';
    });
  }
}

  void _novaPergunta() {
  // Se todos os países já foram usados, inicia outra rodada.
  if (_paisesRestantes.isEmpty) {
    _paisesRestantes = List<Pais>.from(_paisesDisponiveis);
  }

  // Embaralha os países restantes.
  _paisesRestantes.shuffle(_random);

  // Evita repetir o país da pergunta anterior,
  // inclusive quando uma nova rodada começa.
  if (_paisesRestantes.length > 1 &&
      _paisesRestantes.first.nome == _ultimoPaisNome) {
    final indiceDiferente = _paisesRestantes.indexWhere(
      (pais) => pais.nome != _ultimoPaisNome,
    );

    if (indiceDiferente > 0) {
      final temporario = _paisesRestantes[0];
      _paisesRestantes[0] = _paisesRestantes[indiceDiferente];
      _paisesRestantes[indiceDiferente] = temporario;
    }
  }

  // Seleciona e remove o próximo país.
  _paisAtual = _paisesRestantes.removeAt(0);

  // Guarda o país atual para evitar repetição consecutiva.
  _ultimoPaisNome = _paisAtual.nome;

  // Cria três alternativas erradas diferentes.
  final outrasOpcoes = _paisesDisponiveis
      .where((pais) => pais.nome != _paisAtual.nome)
      .toList()
    ..shuffle(_random);

  _alternativas = [
    _paisAtual,
    ...outrasOpcoes.take(3),
  ]..shuffle(_random);

  _respondida = false;
  _acertou = null;
  _respostaEscolhida = null;
}
  void _iniciarCronometro() {
    _cronometro = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) return;

        if (_tempoRestante <= 1) {
          setState(() => _tempoRestante = 0);
          _encerrarJogo();
        } else {
          setState(() => _tempoRestante--);
        }
      },
    );
  }

  void _responder(Pais pais) {
    if (_respondida || _tempoRestante <= 0) return;

    final correto = pais.nome == _paisAtual.nome;

    setState(() {
      _respondida = true;
      _acertou = correto;
      _respostaEscolhida = pais.nome;
      _respondidas++;

      if (correto) {
        _acertos++;
        _pontos += widget.dificuldade == 'Difícil' ? 2 : 1;
      }
    });

    _transicao?.cancel();
    _transicao = Timer(
      const Duration(milliseconds: 900),
      () {
        if (!mounted) return;

        if (_tempoRestante <= 0) {
          _encerrarJogo();
          return;
        }

        setState(_novaPergunta);
      },
    );
  }

  void _encerrarJogo() {
    if (!mounted) return;

    _cronometro?.cancel();
    _transicao?.cancel();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TelaResultados(
          acertos: _acertos,
          respondidas: _respondidas,
          continente: widget.continente,
          dificuldade: widget.dificuldade,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cronometro?.cancel();
    _transicao?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_erroCarregamento != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                Text(_erroCarregamento!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Voltar ao menu'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final progresso = _tempoRestante / widget.tempo;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Desafio das bandeiras',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: fundoJogo,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Encerrar partida',
            onPressed: _encerrarJogo,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.public, color: roxoJogo),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.continente} • ${widget.dificuldade}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Icon(Icons.stars, color: Color(0xFFFFD166)),
                  const SizedBox(width: 6),
                  Text(
                    '$_pontos pontos',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cartaoJogo,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer,
                          color: _tempoRestante <= 10
                              ? vermelhoJogo
                              : verdeJogo,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_tempoRestante}s restantes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _tempoRestante <= 10
                                ? vermelhoJogo
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progresso.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: fundoJogo,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _tempoRestante <= 10
                              ? vermelhoJogo
                              : verdeJogo,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'A qual país pertence esta bandeira?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 22),

              Container(
                height: 190,
                decoration: BoxDecoration(
                  color: cartaoJogo,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Image.network(
                      _paisAtual.bandeira,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Text(
                        _paisAtual.emoji,
                        style: const TextStyle(fontSize: 100),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'ESCOLHA UMA RESPOSTA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 14),

              ..._alternativas.map((pais) {
                Color cor = cartaoJogo;

                if (_respondida && pais.nome == _paisAtual.nome) {
                  cor = verdeJogo.withValues(alpha: 0.25);
                } else if (_respondida &&
                    pais.nome == _respostaEscolhida &&
                    _acertou == false) {
                  cor = vermelhoJogo.withValues(alpha: 0.25);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: cor,
                    borderRadius: BorderRadius.circular(17),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(17),
                      onTap: () => _responder(pais),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(17),
                          border: Border.all(
                            color: _respondida &&
                                    pais.nome == _paisAtual.nome
                                ? verdeJogo
                                : Colors.white10,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                pais.nome,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (_respondida &&
                                pais.nome == _paisAtual.nome)
                              const Icon(
                                Icons.check_circle,
                                color: verdeJogo,
                              )
                            else if (_respondida &&
                                pais.nome == _respostaEscolhida &&
                                _acertou == false)
                              const Icon(
                                Icons.cancel,
                                color: vermelhoJogo,
                              )
                            else
                              const Icon(
                                Icons.circle_outlined,
                                color: Colors.white30,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              if (_respondida) ...[
                const SizedBox(height: 8),
                Text(
                  _acertou == true
                      ? 'Muito bem! Você acertou!'
                      : 'Quase! A resposta era ${_paisAtual.nome}.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _acertou == true
                        ? verdeJogo
                        : vermelhoJogo,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],

              const SizedBox(height: 12),

              Text(
                'Perguntas respondidas: $_respondidas',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TelaResultados extends StatefulWidget {
  final int acertos;
  final int respondidas;
  final String continente;
  final String dificuldade;

  const TelaResultados({
    super.key,
    required this.acertos,
    required this.respondidas,
    required this.continente,
    required this.dificuldade,
  });

  @override
  State<TelaResultados> createState() => _TelaResultadosState();
}

class _TelaResultadosState extends State<TelaResultados> {
  int _recorde = 0;
  bool _carregandoRecorde = true;
  bool _novoRecorde = false;

  String get _chaveRecorde => 'recorde_${widget.continente}';

  @override
  void initState() {
    super.initState();
    _carregarESalvarRecorde();
  }

  Future<void> _carregarESalvarRecorde() async {
    final preferencias = await SharedPreferences.getInstance();
    final recordeAnterior = preferencias.getInt(_chaveRecorde) ?? 0;
    final bateuRecorde = widget.acertos > recordeAnterior;
    final recordeAtual =
        bateuRecorde ? widget.acertos : recordeAnterior;

    if (bateuRecorde) {
      await preferencias.setInt(_chaveRecorde, recordeAtual);
    }

    if (!mounted) return;

    setState(() {
      _recorde = recordeAtual;
      _novoRecorde = bateuRecorde;
      _carregandoRecorde = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final percentual = widget.respondidas == 0
        ? 0.0
        : (widget.acertos / widget.respondidas) * 100;

    return Scaffold(
      backgroundColor: fundoJogo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: roxoJogo.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 76,
                    color: Color(0xFFFFD166),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _novoRecorde ? 'Novo recorde!' : 'Fim de jogo!',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _novoRecorde
                      ? 'Parabéns! Você superou sua melhor pontuação.'
                      : 'Confira como você se saiu.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white60),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cartaoJogo,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'SUA PONTUAÇÃO',
                        style: TextStyle(
                          color: Colors.white60,
                          letterSpacing: 2,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${widget.acertos}',
                        style: const TextStyle(
                          fontSize: 64,
                          color: roxoJogo,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text('respostas corretas'),
                      const SizedBox(height: 24),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 16),
                      _estatistica(
                        'Perguntas respondidas',
                        '${widget.respondidas}',
                      ),
                      const SizedBox(height: 18),
                      _estatistica(
                        'Total de acertos',
                        '${widget.acertos}',
                      ),
                      const SizedBox(height: 18),
                      _estatistica(
                        'Percentual de acertos',
                        '${percentual.toStringAsFixed(1)}%',
                      ),
                      const SizedBox(height: 18),
                      _estatistica(
                        'Modo de jogo',
                        widget.continente,
                      ),
                      const SizedBox(height: 18),
                      _estatistica(
                        'Dificuldade',
                        widget.dificuldade,
                      ),
                      const SizedBox(height: 18),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Color(0xFFFFD166),
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Seu recorde neste modo',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          if (_carregandoRecorde)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          else
                            Text(
                              '$_recorde',
                              style: const TextStyle(
                                color: Color(0xFFFFD166),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.popUntil(
                        context,
                        (route) => route.isFirst,
                      );
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Voltar ao menu'),
                    style: FilledButton.styleFrom(
                      backgroundColor: roxoJogo,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _estatistica(String titulo, String valor) {
    return Row(
      children: [
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        Text(
          valor,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

