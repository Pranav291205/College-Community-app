import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Placement Leaderboard',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First Graph - Placement Statistics
              _buildGraphCard(
                title: 'Placement Statistics 2024',
                graph: _buildBarChart(),
              ),
              const SizedBox(height: 24),

              // Second Graph - Branch-wise Placements
              _buildGraphCard(
                title: 'Branch-wise Placements',
                graph: _buildLineChart(),
              ),
              const SizedBox(height: 24),

              // Top Placements Title
              const Text(
                'Top Placements',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Horizontal Scrollable Cards
              SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 13,
                  itemBuilder: (context, index) {
                    return _buildPlacementCard(index + 1);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGraphCard({required String title, required Widget graph}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: graph),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const titles = ['CS', 'IT', 'ECE', 'ME', 'CE'];
                if (value.toInt() >= 0 && value.toInt() < titles.length) {
                  return Text(
                    titles[value.toInt()],
                    style: const TextStyle(fontSize: 12),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [BarChartRodData(toY: 85, color: Colors.blue, width: 20)],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [BarChartRodData(toY: 78, color: Colors.green, width: 20)],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(toY: 72, color: Colors.orange, width: 20),
            ],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [BarChartRodData(toY: 65, color: Colors.red, width: 20)],
          ),
          BarChartGroupData(
            x: 4,
            barRods: [
              BarChartRodData(toY: 58, color: Colors.purple, width: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const titles = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                if (value.toInt() >= 0 && value.toInt() < titles.length) {
                  return Text(
                    titles[value.toInt()],
                    style: const TextStyle(fontSize: 12),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 20),
              FlSpot(1, 35),
              FlSpot(2, 50),
              FlSpot(3, 65),
              FlSpot(4, 75),
              FlSpot(5, 85),
            ],
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacementCard(int rank) {
    // Sample data with package information
    final placements = [
      {
        'name': 'Anshuman Nandan',
        'branch': 'Computer Science',
        'company': 'Google',
        'package': '₹30 LPA',
        'image': 'assets/1.png',
      },
      {
        'name': 'Archas Srivastava',
        'branch': 'Information Technology',
        'company': 'Goldman Sachs',
        'package': '₹21 LPA',
        'image': 'assets/2.png',
      },
      {
        'name': 'Soumya Maheshwari',
        'branch': 'Computer Science',
        'company': 'Googe',
        'package': '₹13.2 LPA',
        'image': 'assets/3.png',
      },
      {
        'name': 'Garima Gautam',
        'branch': 'Electronics',
        'company': 'Amazon',
        'package': '₹13.2 LPA',
        'image': 'assets/4.png',
      },
      {
        'name': 'SAKSHAM TIWARI',
        'branch': 'Computer Science',
        'company': 'Meta',
        'package': '₹42.75 LPA',
        'image': 'assets/5.png',
      },
      {
        'name': 'SAUMYA CHAUDHARY',
        'branch': 'Information Technology',
        'company': 'Uber',
        'package': '₹38.44 LPA',
        'image': 'assets/6.png',
      },
      {
        'name': 'SUYASH SINGH',
        'branch': 'Computer Science',
        'company': 'Netflix',
        'package': '₹34 LPA',
        'image': 'assets/7.png',
      },
      {
        'name': 'PARAS PANDEY',
        'branch': 'Electronics',
        'company': 'Intel',
        'package': '₹32 LPA',
        'image': 'assets/8.png',
      },
      {
        'name': 'SHREYANSHI SINGH ',
        'branch': 'Computer Science',
        'company': 'PhonePe',
        'package': '₹30 LPA',
        'image': 'assets/9.png',
      },
      {
        'name': 'APOORV MAHESHWARI B. ',
        'branch': 'Information Technology',
        'company': 'Salesforce',
        'package': '₹28 LPA',
        'image': 'assets/10.png',
      },
      {
        'name': 'DEEPAK SHARMA',
        'branch': 'Computer Science',
        'company': 'Oracle',
        'package': '₹26 LPA',
        'image': 'assets/11.png',
      },
      {
        'name': 'MADHUR VASHISTHA B. ',
        'branch': 'Electronics',
        'company': 'Qualcomm',
        'package': '₹25 LPA',
        'image': 'assets/12.png',
      },
      {
        'name': 'MUSKAN AGRAWAL ',
        'branch': 'Computer Science',
        'company': 'LinkedIn',
        'package': '₹24 LPA',
        'image': 'assets/13.png',
      },
    ];

    final data = placements[rank - 1];

    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Person's Image
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          data['image']!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to gradient with initial if image not found
                            return Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.primaries[rank %
                                        Colors.primaries.length],
                                    Colors.primaries[(rank + 3) %
                                        Colors.primaries.length],
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  data['name']![0],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Person's Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            data['name']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data['branch']!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Company Tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.business, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          data['company']!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Package Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade50, Colors.green.shade100],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.currency_rupee,
                        size: 18,
                        color: Colors.green[800],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Package: ',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        data['package']!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Rank Badge
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getRankColor(rank),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _getRankColor(rank).withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber.shade600;
    if (rank == 2) return Colors.grey[400]!;
    if (rank == 3) return Colors.brown[400]!;
    return Colors.blue;
  }
}
