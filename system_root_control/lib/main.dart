import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const SystemRootApp());
}

class SystemRootApp extends StatelessWidget {
  const SystemRootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.cyanAccent,
        colorScheme: const ColorScheme.dark(primary: Colors.cyanAccent),
      ),
      home: const Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final TextEditingController _temaController = TextEditingController();

  // Variáveis de Controle Analítico
  String _deployStatus = "IDLE";
  Color _statusColor = Colors.orangeAccent;
  double _progressoTransmissao = 0.0;
  int _segundosDecorridos = 0;
  int? _tempoFinalProcessamento; // Tempo real de resposta do GitHub
  Timer? _progressoTimer;
  Timer? _statusCheckTimer; // Sonda de verificação da API

  late String githubToken;
  final String repoOwner = "lucasmdcv";
  final String repoName = "blog-dark-analitico";

  final List<Map<String, String>> _logs = [];

  final List<String> _temasAleatorios = [
    "Protocolos de Shadow IT: Como identificar dispositivos fantasmas na rede",
    "Engenharia Reversa em Python: Desmontando scripts de automação maliciosos",
    "A estética de vigilância de Person of Interest: Realidade ou ficção em 2026?",
    "Otimização de rotinas Java para processamento massivo de logs analíticos",
    "Cybersecurity no DF: Vulnerabilidades comuns em infraestruturas locais",
    "Análise forense digital: Seguindo o rastro de dados como um Dexter de sistemas",
    "Automatizando Pentests com Selenium e Python: O futuro do QA agressivo",
    "A lógica de Solo Leveling: Como 'subir de nível' em arquitetura de dados",
    "Monitoramento em tempo real: Criando dashboards que Finch (PoI) aprovaria",
    "Segurança em IoT: Por que sua impressora 3D Neptune pode ser uma brecha",
  ];

  @override
  void initState() {
    super.initState();
    githubToken = dotenv.env['GITHUB_TOKEN'] ?? "";
    _buscarDadosReais();
  }

  // Sonda que pergunta ao GitHub se a Action terminou
  Future<void> _verificarStatusAction() async {
    final url = Uri.parse('https://api.github.com/repos/$repoOwner/$repoName/actions/runs?per_page=1');
    
    _statusCheckTimer?.cancel();
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final response = await http.get(url, headers: {
          'Authorization': 'Bearer $githubToken',
          'Accept': 'application/vnd.github+json',
        });

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final lastRun = data['workflow_runs'][0];
          String status = lastRun['status']; // 'queued', 'in_progress', 'completed'
          String conclusion = lastRun['conclusion'] ?? ""; // 'success', 'failure'

          if (status == "completed") {
            timer.cancel();
            _progressoTimer?.cancel(); // Para o cronômetro visual
            setState(() {
              _tempoFinalProcessamento = _segundosDecorridos;
              _deployStatus = conclusion == "success" ? "CONCLUÍDO" : "FALHA GH";
              _statusColor = conclusion == "success" ? Colors.greenAccent : Colors.redAccent;
            });
            _buscarDadosReais(); // Sincroniza os logs logo após o término
          }
        }
      } catch (e) {
        timer.cancel();
      }
    });
  }

  void _iniciarBarraProgresso() {
    _progressoTimer?.cancel();
    setState(() {
      _progressoTransmissao = 0.0;
      _segundosDecorridos = 0;
      _tempoFinalProcessamento = null;
    });

    _progressoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _segundosDecorridos++;
        if (_progressoTransmissao < 0.95) {
          _progressoTransmissao += 1 / 60;
        } else {
          // Barra fica em 95% até o GitHub avisar que acabou
        }
      });
    });
  }

  Future<void> _buscarDadosReais() async {
    final url = Uri.parse(
      'https://raw.githubusercontent.com/$repoOwner/$repoName/main/post.json?t=${DateTime.now().millisecondsSinceEpoch}',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        setState(() {
          _logs.clear();
          for (var item in dados) {
            _logs.add({
              "hash": "SYSTEM",
              "msg": item['titulo'] ?? "Sem título",
              "data": "ONLINE",
            });
          }
        });
      }
    } catch (e) {
      debugPrint("Erro ao buscar dados: $e");
    }
  }

  Future<void> _dispararExecucao(String tema) async {
    setState(() {
      _deployStatus = "TRANSMITINDO...";
      _statusColor = Colors.blueAccent;
    });

    _iniciarBarraProgresso();

    final url = Uri.parse(
      'https://api.github.com/repos/$repoOwner/$repoName/actions/workflows/postar.yml/dispatches',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $githubToken',
          'Accept': 'application/vnd.github+json',
        },
        body: jsonEncode({
          'ref': 'main',
          'inputs': {'tema': tema},
        }),
      );

      if (response.statusCode == 204) {
        _verificarStatusAction(); // INICIA O MONITORAMENTO REAL
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Protocolo aceito pelo GitHub (Status 204)"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _deployStatus = "ERRO: ${response.statusCode}";
          _statusColor = Colors.redAccent;
        });
      }
    } catch (e) {
      setState(() {
        _deployStatus = "OFFLINE/TIMEOUT";
        _statusColor = Colors.redAccent;
      });
    }
  }

  void _abrirSite() async {
    final url = Uri.parse('https://blog-dark-analitico.netlify.app/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SYSTEM_ROOT > CONTROL", style: TextStyle(fontFamily: 'monospace')),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: _buscarDadosReais,
            icon: const Icon(Icons.refresh, color: Colors.cyanAccent),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text("DIRETRIZ DE ENTRADA: QUAL O TEMA DO POST?",
                      style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _temaController,
                    decoration: const InputDecoration(hintText: "Ex: Série You Netflix...", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: () {
                      String tema = _temaController.text;
                      if (tema.isEmpty) {
                        _temasAleatorios.shuffle();
                        tema = _temasAleatorios.first;
                      }
                      _dispararExecucao(tema);
                    },
                    icon: const Icon(Icons.bolt),
                    label: const Text("EXECUTAR: NOVO BLOG"),
                  ),
                  
                  if (_deployStatus == "TRANSMITINDO..." || _tempoFinalProcessamento != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Column(
                        children: [
                          LinearProgressIndicator(
                            value: _progressoTransmissao,
                            backgroundColor: Colors.white10,
                            color: _tempoFinalProcessamento == null ? Colors.cyanAccent : Colors.greenAccent,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _tempoFinalProcessamento == null 
                                    ? "TEMPO: ${_segundosDecorridos}s" 
                                    : "TEMPO TOTAL GH: ${_tempoFinalProcessamento}s",
                                style: TextStyle(
                                  color: _tempoFinalProcessamento == null ? Colors.cyanAccent : Colors.greenAccent,
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${(_progressoTransmissao * 100).toStringAsFixed(0)}% CONCLUÍDO",
                                style: const TextStyle(color: Colors.cyanAccent, fontSize: 10, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(4),
                border: const Border(left: BorderSide(color: Colors.cyanAccent, width: 3)),
              ),
              child: Column(
                children: [
                  _buildStatusRow("MOTOR IA (LLAMA-3)", "OPERACIONAL", Colors.greenAccent),
                  const SizedBox(height: 5),
                  _buildStatusRow("GITHUB ACTION", _deployStatus, _statusColor),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("TRANSMISSÕES RECENTES (LOGS):", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    color: Colors.white.withOpacity(0.05),
                    child: Row(
                      children: [
                        Text("[${_logs[index]['hash']}]", style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace')),
                        const SizedBox(width: 10),
                        Expanded(child: Text(_logs[index]['msg']!, overflow: TextOverflow.ellipsis)),
                        Text(_logs[index]['data']!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String status, Color statusColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.grey)),
        Text(status, style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: statusColor, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  void dispose() {
    _progressoTimer?.cancel();
    _statusCheckTimer?.cancel();
    _temaController.dispose();
    super.dispose();
  }
}