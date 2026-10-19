import 'package:flutter/material.dart';
import 'package:safe_json_mapper/safe_json_mapper.dart';
import 'package:safe_json_mapper_example/models.dart';

void main() {
  // Initialize models once at startup
  initModels();

  // You can globally configure the error policy
  SafeJsonMapper.errorPolicy = SafeJsonModelErrorPolicy.logAndDefault;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeJsonMapper Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SafeModelDemo(),
    );
  }
}

class SafeModelDemo extends StatefulWidget {
  const SafeModelDemo({super.key});

  @override
  State<SafeModelDemo> createState() => _SafeModelDemoState();
}

class _SafeModelDemoState extends State<SafeModelDemo> {
  String _result = "Select a scenario to witness SafeModel's power";
  String _jsonInput = "{}";

  void _testUser(String title, Map<String, dynamic> json) {
    try {
      final user = SafeJsonMapper.fromJson<User>(json);
      setState(() {
        _jsonInput = _prettyJson(json);
        _result =
            """
Scenario: $title
Result: ✅ PARSED
-----------------------------
ID: ${user.id}
Name: ${user.name}
Active: ${user.isActive}
Rating: ${user.rating}
Tags: ${user.tags.join(', ')}
Posts: ${user.posts.length}
Profile: ${user.profile != null ? "Age ${user.profile!.age}" : "None"}
""";
      });
    } catch (e) {
      setState(() {
        _jsonInput = _prettyJson(json);
        _result = "Error in $title: $e";
      });
    }
  }

  void _testApiResponse(String title, Map<String, dynamic> json) {
    try {
      final response = SafeJsonMapper.fromJson<ApiResponse>(json);
      setState(() {
        _jsonInput = _prettyJson(json);
        final user = response.data;
        _result =
            """
Scenario: $title
Result: ${response.success ? "✅ SUCCESS" : "❌ FAILED"}
Message: ${response.message}
-----------------------------
${user != null ? "User ID: ${user.id}\nUser Name: ${user.name}\nActive: ${user.isActive}" : "No User Data"}
""";
      });
    } catch (e) {
      setState(() {
        _jsonInput = _prettyJson(json);
        _result = "Error in $title: $e";
      });
    }
  }

  String _prettyJson(Map<String, dynamic> json) {
    // Simple pretty print
    return json
        .toString()
        .replaceAll('{', '{\n  ')
        .replaceAll(', ', ',\n  ')
        .replaceAll('}', '\n}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛡️ SafeJsonMapper Demo'),
        actions: [
          PopupMenuButton<SafeJsonModelErrorPolicy>(
            icon: const Icon(Icons.settings),
            initialValue: SafeJsonMapper.errorPolicy,
            onSelected: (policy) {
              setState(() {
                SafeJsonMapper.errorPolicy = policy;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SafeJsonModelErrorPolicy.throwError,
                child: Text("Policy: Throw"),
              ),
              const PopupMenuItem(
                value: SafeJsonModelErrorPolicy.logAndDefault,
                child: Text("Policy: Log & Fallback"),
              ),
              const PopupMenuItem(
                value: SafeJsonModelErrorPolicy.silent,
                child: Text("Policy: Silent"),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle("Current Input JSON"),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal.withValues(alpha: 0.5)),
                ),
                child: Text(
                  _jsonInput,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("Parsing Result"),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _result,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Scenarios"),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _scenarioButton("Perfect Success", {
                    "success": true,
                    "message": "Data retrieved successfully",
                    "data": {
                      "id": 1,
                      "full_name": "GreeLogix Expert",
                      "isActive": true,
                      "rating": 5,
                      "tags": ["success", "accurate"],
                      "posts": [],
                      "profile": {"age": 25, "score": 100},
                    },
                  }, isApiResponse: true),
                  _scenarioButton("Optimal JSON", {
                    "id": 1,
                    "full_name": "Antigravity AI",
                    "isActive": true,
                    "rating": 5.0,
                    "tags": ["safe", "robust"],
                    "posts": [
                      {"title": "Hello World"},
                    ],
                    "profile": {"age": 20, "score": 99},
                  }),
                  _scenarioButton("Type & Case Drift", {
                    "id": "42",
                    "full_name": "Drift Master",
                    "isActive": 1,
                    "rating": "4.5",
                    "tags": [1, 2, "three"], // Mixed types in list
                    "posts": [{}], // Empty object instead of post
                    "profile": {"age": "25.5", "score": "88"},
                  }),
                  _scenarioButton("Nulls & Missing", {
                    "id": 101,
                    "isActive": "true",
                    // Missing lists, missing profile, missing rating
                  }),
                  _scenarioButton("Invalid Nested", {
                    "id": 202,
                    "isActive": false,
                    "profile": "this should be a map",
                    "posts": "this should be a list",
                  }),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: bold, color: Colors.teal),
      ),
    );
  }

  Widget _scenarioButton(
    String label,
    Map<String, dynamic> data, {
    bool isApiResponse = false,
  }) {
    return ElevatedButton(
      onPressed: () => isApiResponse
          ? _testApiResponse(label, data)
          : _testUser(label, data),
      child: Text(label),
    );
  }
}

const bold = FontWeight.bold;
