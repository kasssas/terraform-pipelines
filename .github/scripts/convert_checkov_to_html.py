#!/usr/bin/env python3
"""
Convert Checkov JUnit XML report to a beautiful HTML report.
"""
import xml.etree.ElementTree as ET
import sys

def convert_junit_to_html(xml_file, html_file):
    try:
        tree = ET.parse(xml_file)
        root = tree.getroot()
        
        html_content = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkov Security Scan Report</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f7fa; padding: 20px; }
        .container { max-width: 1200px; margin: 0 auto; background: white; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 8px 8px 0 0; }
        .header h1 { font-size: 28px; margin-bottom: 10px; }
        .header p { opacity: 0.9; font-size: 14px; }
        .summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; padding: 30px; border-bottom: 1px solid #e1e8ed; }
        .summary-card { background: #f8f9fa; padding: 20px; border-radius: 6px; border-left: 4px solid #667eea; }
        .summary-card h3 { color: #6c757d; font-size: 12px; text-transform: uppercase; margin-bottom: 8px; letter-spacing: 0.5px; }
        .summary-card .value { font-size: 32px; font-weight: bold; color: #2d3748; }
        .summary-card.passed { border-left-color: #48bb78; }
        .summary-card.passed .value { color: #48bb78; }
        .summary-card.failed { border-left-color: #f56565; }
        .summary-card.failed .value { color: #f56565; }
        .summary-card.skipped { border-left-color: #ed8936; }
        .summary-card.skipped .value { color: #ed8936; }
        .results { padding: 30px; }
        .results h2 { color: #2d3748; margin-bottom: 20px; font-size: 20px; }
        .test-case { background: #f8f9fa; margin-bottom: 15px; border-radius: 6px; overflow: hidden; border: 1px solid #e1e8ed; }
        .test-case.failed { border-left: 4px solid #f56565; }
        .test-case.passed { border-left: 4px solid #48bb78; }
        .test-case.skipped { border-left: 4px solid #ed8936; }
        .test-header { padding: 15px 20px; display: flex; justify-content: space-between; align-items: center; cursor: pointer; background: white; }
        .test-header:hover { background: #f8f9fa; }
        .test-name { font-weight: 600; color: #2d3748; flex: 1; }
        .test-status { padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: 600; text-transform: uppercase; }
        .test-status.passed { background: #c6f6d5; color: #22543d; }
        .test-status.failed { background: #fed7d7; color: #742a2a; }
        .test-status.skipped { background: #feebc8; color: #7c2d12; }
        .test-details { padding: 20px; background: #ffffff; border-top: 1px solid #e1e8ed; display: none; }
        .test-details.active { display: block; }
        .test-details pre { background: #2d3748; color: #e2e8f0; padding: 15px; border-radius: 4px; overflow-x: auto; font-size: 13px; line-height: 1.5; }
        .filter-buttons { padding: 20px 30px; border-bottom: 1px solid #e1e8ed; display: flex; gap: 10px; }
        .filter-btn { padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; font-weight: 600; font-size: 14px; transition: all 0.3s; }
        .filter-btn.active { background: #667eea; color: white; }
        .filter-btn:not(.active) { background: #e1e8ed; color: #4a5568; }
        .filter-btn:hover:not(.active) { background: #cbd5e0; }
        .empty-state { text-align: center; padding: 60px 20px; color: #a0aec0; }
        .empty-state svg { width: 64px; height: 64px; margin-bottom: 16px; opacity: 0.5; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔒 Checkov Security Scan Report</h1>
            <p>Terraform Infrastructure Security Analysis</p>
        </div>
'''
        
        # Calculate summary
        total_tests = 0
        passed = 0
        failed = 0
        skipped = 0
        
        test_cases = []
        
        for testsuite in root.findall('testsuite'):
            for testcase in testsuite.findall('testcase'):
                total_tests += 1
                name = testcase.get('name', 'Unknown')
                classname = testcase.get('classname', '')
                
                failure = testcase.find('failure')
                skipped_elem = testcase.find('skipped')
                
                if failure is not None:
                    status = 'failed'
                    failed += 1
                    message = failure.get('message', '')
                    details = failure.text or ''
                elif skipped_elem is not None:
                    status = 'skipped'
                    skipped += 1
                    message = skipped_elem.get('message', '')
                    details = skipped_elem.text or ''
                else:
                    status = 'passed'
                    passed += 1
                    message = ''
                    details = ''
                
                test_cases.append({
                    'name': name,
                    'classname': classname,
                    'status': status,
                    'message': message,
                    'details': details
                })
        
        # Add summary cards
        html_content += f'''
        <div class="summary">
            <div class="summary-card">
                <h3>Total Checks</h3>
                <div class="value">{total_tests}</div>
            </div>
            <div class="summary-card passed">
                <h3>Passed</h3>
                <div class="value">{passed}</div>
            </div>
            <div class="summary-card failed">
                <h3>Failed</h3>
                <div class="value">{failed}</div>
            </div>
            <div class="summary-card skipped">
                <h3>Skipped</h3>
                <div class="value">{skipped}</div>
            </div>
        </div>
        
        <div class="filter-buttons">
            <button class="filter-btn active" onclick="filterTests('all')">All ({total_tests})</button>
            <button class="filter-btn" onclick="filterTests('failed')">Failed ({failed})</button>
            <button class="filter-btn" onclick="filterTests('passed')">Passed ({passed})</button>
            <button class="filter-btn" onclick="filterTests('skipped')">Skipped ({skipped})</button>
        </div>
        
        <div class="results">
            <h2>Detailed Results</h2>
'''
        
        # Add test cases
        if test_cases:
            for idx, tc in enumerate(test_cases):
                tc_name = tc['name'].replace('<', '&lt;').replace('>', '&gt;')
                tc_class = tc['classname'].replace('<', '&lt;').replace('>', '&gt;')
                tc_msg = tc['message'].replace('<', '&lt;').replace('>', '&gt;')
                tc_details = tc['details'].replace('<', '&lt;').replace('>', '&gt;')
                
                html_content += f'''
            <div class="test-case {tc['status']}" data-status="{tc['status']}">
                <div class="test-header" onclick="toggleDetails(this)">
                    <div class="test-name">{tc_name}</div>
                    <span class="test-status {tc['status']}">{tc['status']}</span>
                </div>
'''
                if tc['message'] or tc['details']:
                    html_content += f'''
                <div class="test-details" id="details-{idx}">
                    {f'<p><strong>Message:</strong> {tc_msg}</p>' if tc_msg else ''}
                    {f'<pre>{tc_details}</pre>' if tc_details else ''}
                </div>
'''
                html_content += '    </div>\n'
        else:
            html_content += '''
            <div class="empty-state">
                <p>No test results found</p>
            </div>
'''
        
        html_content += '''
        </div>
    </div>
    
    <script>
        function toggleDetails(header) {
            const details = header.nextElementSibling;
            if (details && details.classList.contains('test-details')) {
                details.classList.toggle('active');
            }
        }
        
        function filterTests(status) {
            const tests = document.querySelectorAll('.test-case');
            const buttons = document.querySelectorAll('.filter-btn');
            
            buttons.forEach(btn => btn.classList.remove('active'));
            event.target.classList.add('active');
            
            tests.forEach(test => {
                if (status === 'all' || test.dataset.status === status) {
                    test.style.display = 'block';
                } else {
                    test.style.display = 'none';
                }
            });
        }
    </script>
</body>
</html>
'''
        
        with open(html_file, 'w', encoding='utf-8') as f:
            f.write(html_content)
        
        print(f"✓ Successfully converted {xml_file} to {html_file}")
        
    except Exception as e:
        print(f"✗ Error converting XML to HTML: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    input_file = sys.argv[1] if len(sys.argv) > 1 else 'checkov-report.xml'
    output_file = sys.argv[2] if len(sys.argv) > 2 else 'checkov-report.html'
    convert_junit_to_html(input_file, output_file)
