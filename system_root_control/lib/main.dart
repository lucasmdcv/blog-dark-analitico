import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
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

  // Dados de Conexão (Puxando do .env no momento certo)
  late String githubToken;
  final String repoOwner = "lucasmdcv"; // Seu usuário GitHub
  final String repoName = "blog-dark-analitico";

  // Lista de Logs (Simulada)
  final List<Map<String, String>> _logs = [
    {"hash": "35da94a", "msg": "Novo post via script automatizado", "data": "10/01 13:52"},
    {"hash": "a2b4c1d", "msg": "Ajuste no motor de IA", "data": "10/01 12:30"},
  ];

  @override
  void initState() {
    super.initState();
    // Inicializa o token após o carregamento do Main
    githubToken = dotenv.env['GITHUB_TOKEN'] ?? "";
  }

  // Função para disparar a automação via API do GitHub
  Future<void> _dispararExecucao(String tema) async {
    setState(() {
      _deployStatus = "TRANSMITINDO...";
      _statusColor = Colors.blueAccent;
    });

    final url = Uri.parse('https://api.github.com/repos/$repoOwner/$repoName/actions/workflows/postar.yml/dispatches');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $githubToken',
          'Accept': 'application/vnd.github+json',
        },
        body: jsonEncode({
          'ref': 'main',
          'inputs': {'tema': tema}
        }),
      );

      if (response.statusCode == 204) {
        setState(() {
          _deployStatus = "SUCCESS (GH)";
          _statusColor = Colors.greenAccent;
          _logs.insert(0, {"hash": "transm", "msg": "SYSTEM_ROOT: $tema", "data": "Agora"});
        });
      } else {
        setState(() {
          _deployStatus = "ERR: ${response.statusCode}";
          _statusColor = Colors.redAccent;
        });
      }
    } catch (e) {
      setState(() {
        _deployStatus = "OFFLINE";
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
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh, color: Colors.cyanAccent),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SEÇÃO: INPUT DE TEMA
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
                    decoration: const InputDecoration(
                      hintText: "Ex: Série You Netflix...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: () {
                      if (_temaController.text.isNotEmpty) {
                        _dispararExecucao(_temaController.text);
                      }
                    },
                    icon: const Icon(Icons.bolt),
                    label: const Text("EXECUTAR: NOVO BLOG"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            // SEÇÃO: STATUS ANALÍTICO
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
                  _buildStatusRow("CONEXÃO GITHUB", githubToken.isNotEmpty ? "ONLINE" : "MISSING TOKEN",
                      githubToken.isNotEmpty ? Colors.greenAccent : Colors.redAccent),
                  const SizedBox(height: 5),
                  _buildStatusRow("DEPLOY NETLIFY", _deployStatus, _statusColor),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // BOTÃO ACESSAR SITE
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed: _abrirSite,
              icon: const Icon(Icons.language),
              label: const Text("ACESSAR TERMINAL WEB (SITE)"),
            ),
            const SizedBox(height: 20),
            const Text("TRANSMISSÕES RECENTES (LOGS):", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
            const SizedBox(height: 10),
            // LISTA DE LOGS (HISTÓRICO)
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
}