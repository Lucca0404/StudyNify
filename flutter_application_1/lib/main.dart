import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const StudyNotifyApp());
}

class Atividade {
  const Atividade({
    required this.id,
    required this.titulo,
    required this.disciplina,
    required this.prazo,
    required this.descricao,
  });

  final String id;
  final String titulo;
  final String disciplina;
  final String prazo;
  final String descricao;
}

const atividades = [
  Atividade(
    id: '1',
    titulo: 'Trabalho de Flutter',
    disciplina: 'Programação para Dispositivos Móveis',
    prazo: '15/11/2026',
    descricao: 'Finalize o aplicativo e prepare a demonstração da entrega.',
  ),
  Atividade(
    id: '2',
    titulo: 'Lista de Algoritmos',
    disciplina: 'Análise de Algoritmos',
    prazo: '18/11/2026',
    descricao: 'Resolva a lista e revise a complexidade das soluções.',
  ),
  Atividade(
    id: '3',
    titulo: 'Estudar para a prova',
    disciplina: 'Sistemas Distribuídos',
    prazo: '20/11/2026',
    descricao: 'Revise o conteúdo das aulas e refaça os exercícios.',
  ),
];

class StudyNotifyApp extends StatelessWidget {
  const StudyNotifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyNotify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
      ),
      home: const TelaInicial(),
    );
  }
}

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  StreamSubscription<RemoteMessage>? _toques;
  StreamSubscription<RemoteMessage>? _mensagensEmPrimeiroPlano;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Toque com o aplicativo em segundo plano.
      _toques = FirebaseMessaging.onMessageOpenedApp.listen(
        _abrirAtividadeDoPush,
      );

      _mensagensEmPrimeiroPlano = FirebaseMessaging.onMessage.listen(
        (mensagem) {
          debugPrint('Push recebido: ${mensagem.notification?.title}');
        },
      );

      unawaited(_verificarMensagemInicial());
      unawaited(_configurarNotificacoes());
    });
  }

  Future<void> _verificarMensagemInicial() async {
    // Toque que iniciou o aplicativo.
    try {
      final mensagem = await FirebaseMessaging.instance.getInitialMessage();
      if (mounted && mensagem != null) {
        _abrirAtividadeDoPush(mensagem);
      }
    } catch (erro) {
      debugPrint('Erro ao ler a notificação de abertura: $erro');
    }
  }

  Future<void> _configurarNotificacoes() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final permissao = await messaging.requestPermission();
      debugPrint('Permissão de notificações: ${permissao.authorizationStatus}');

      if (kDebugMode) {
        final token = await messaging.getToken();
        debugPrint('TOKEN FCM: $token');
      }
    } catch (erro) {
      debugPrint('Erro ao configurar as notificações: $erro');
    }
  }

  void _abrirAtividadeDoPush(RemoteMessage mensagem) {
    if (!mounted) return;

    final id = mensagem.data['atividade_id']?.toString();
    debugPrint('Dados do push tocado: ${mensagem.data}');

    for (final atividade in atividades) {
      if (atividade.id == id) {
        _abrirDetalhes(atividade);
        return;
      }
    }

    debugPrint('Atividade não encontrada para o ID: $id');
  }

  void _abrirDetalhes(Atividade atividade) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TelaDetalhes(atividade: atividade),
      ),
    );
  }

  @override
  void dispose() {
    _toques?.cancel();
    _mensagensEmPrimeiroPlano?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('StudyNotify')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Minhas atividades', style: tema.textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Acompanhe suas próximas entregas.'),
          const SizedBox(height: 16),
          for (final atividade in atividades)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: tema.colorScheme.primary,
                  foregroundColor: tema.colorScheme.onPrimary,
                  child: const Icon(Icons.assignment_outlined),
                ),
                title: Text(
                  atividade.titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${atividade.disciplina}\nPrazo: ${atividade.prazo}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _abrirDetalhes(atividade),
              ),
            ),
        ],
      ),
    );
  }
}

class TelaDetalhes extends StatelessWidget {
  const TelaDetalhes({super.key, required this.atividade});

  final Atividade atividade;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da atividade')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(atividade.titulo, style: tema.textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(atividade.disciplina, style: tema.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Prazo: ${atividade.prazo}'),
          const SizedBox(height: 24),
          Text(atividade.descricao),
        ],
      ),
    );
  }
}