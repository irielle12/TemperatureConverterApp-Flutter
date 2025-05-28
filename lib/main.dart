import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for SystemChrome

void main() {
  // Ensure that Flutter widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Set preferred orientations (optional, but good for consistent behavior)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TemperatureConverterScreen(),
    );
  }
}

class TemperatureConverterScreen extends StatefulWidget {
  const TemperatureConverterScreen({super.key});

  @override
  State<TemperatureConverterScreen> createState() => _TemperatureConverterScreenState();
}

enum ConversionType { fahrenheitToCelsius, celsiusToFahrenheit }

class _TemperatureConverterScreenState extends State<TemperatureConverterScreen> {
  ConversionType _selectedConversion = ConversionType.fahrenheitToCelsius;
  final TextEditingController _temperatureController = TextEditingController();
  String _convertedTemperature = '';
  final List<String> _history = [];

  @override
  void dispose() {
    _temperatureController.dispose();
    super.dispose();
  }

  void _convertTemperature() {
    double? inputValue = double.tryParse(_temperatureController.text);
    if (inputValue == null) {
      setState(() {
        _convertedTemperature = 'Invalid input';
      });
      return;
    }

    double result;
    String historyEntry;

    if (_selectedConversion == ConversionType.fahrenheitToCelsius) {
      result = (inputValue - 32) * 5 / 9;
      historyEntry = 'F to C: ${inputValue.toStringAsFixed(1)} => ${result.toStringAsFixed(2)}';
    } else {
      result = inputValue * 9 / 5 + 32;
      historyEntry = 'C to F: ${inputValue.toStringAsFixed(1)} => ${result.toStringAsFixed(2)}';
    }

    setState(() {
      _convertedTemperature = result.toStringAsFixed(2);
      // Add to the beginning of the list, so most recent is at the top
      _history.insert(0, historyEntry); 
    });
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature Converter'),
        elevation: 4, // Adds a subtle shadow
      ),
      body: orientation == Orientation.portrait
          ? _buildPortraitLayout()
          : _buildLandscapeLayout(),
    );
  }

  // --- Widget Building Methods ---

  Widget _buildConversionSelection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Conversion Type:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            RadioListTile<ConversionType>(
              title: const Text('Fahrenheit to Celsius'),
              value: ConversionType.fahrenheitToCelsius,
              groupValue: _selectedConversion,
              onChanged: (ConversionType? value) {
                setState(() {
                  _selectedConversion = value!;
                });
              },
            ),
            RadioListTile<ConversionType>(
              title: const Text('Celsius to Fahrenheit'),
              value: ConversionType.celsiusToFahrenheit,
              groupValue: _selectedConversion,
              onChanged: (ConversionType? value) {
                setState(() {
                  _selectedConversion = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _temperatureController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Enter Temperature Value',
          hintText: 'e.g., 68.0',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.thermostat_outlined),
        ),
      ),
    );
  }

  Widget _buildConvertButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox( // Use SizedBox to give the button a fixed width
        width: double.infinity, // Make button fill available width
        child: ElevatedButton.icon(
          onPressed: _convertTemperature,
          icon: const Icon(Icons.autorenew),
          label: const Text(
            'Convert',
            style: TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildConvertedResult() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        color: Colors.blue.shade50, // A light blue background
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Converted: ',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.normal),
              ),
              Text(
                _convertedTemperature,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_history.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No conversions yet. History will appear here.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: _history.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              _history[index],
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildConversionSelection(),
          _buildTemperatureInput(),
          _buildConvertButton(),
          _buildConvertedResult(),
          const SizedBox(height: 20),
          // History takes up remaining space, but in a ScrollView, needs a fixed height
          SizedBox(
            height: 250, // You can adjust this height as needed
            child: _buildHistoryList(),
          ),
          const SizedBox(height: 10), // Padding at the bottom
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1, // Left side for input and controls
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildConversionSelection(),
                _buildTemperatureInput(),
                _buildConvertButton(),
                _buildConvertedResult(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1), // Visual separation
        Expanded(
          flex: 1, // Right side for history
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Conversion History:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: _buildHistoryList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}