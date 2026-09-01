# AWSTATS WORMS ADATABASE
#-----------------------------------------------------------------------------
# If you want to add worms to extend AWStats database detection capabilities,
# you must add an entry in WormsSearchIDOrder, WormsHashID and WormsHashLib.
#-----------------------------------------------------------------------------
#package AWSWORMS;
# WormsSearchIDOrder
#-----------------------------------------------------------------------------
@WormsSearchIDOrder = (
    '\/wp-admin\/admin-ajax\.php.*wp_rest',
    '\/\.env',
    '\/\.git\/config',
    '\/api\/v1\/auth',
    '\/actuator\/health',
    '\/actuator\/env',
    '\/actuator\/gateway',
    '\/console\/',
    '\/solr\/admin',
    '\/jmx-console',
    '\/invoker\/JMXInvokerServlet',
    '\/druid\/index.html',
    '\/swagger-ui\.html',
    '\/v2\/_catalog',
    '\/_nodes\/stats',
    '\/_search',
    '\/_sql',
    '\/api\/graphql',
    '\/graphql',
    '\/v1\/graphql',
    
    # 勒索软件相关
    '\/\.wannacry',
    '\/\.badrabbit',
    '\/\.petya',
    '\/\.locky',
    '\/\.cerber',
    '\/\.ryuk',
    '\/\.revil',
    '\/\.darkSide',
    
    # Log4j 相关
    '\$\{jndi:',
    '\$\{env:',
    '\$\{sys:',
    '\$\{java:',
    '\$\{main:',
    '\$\{log4j:',
    
    # Spring4Shell
    '\/spring-framework\/.*class\.module',
    '\/web\/.*class\.module',
    '\/\.\..\/\.\..\/WEB-INF',
    
    # 2020-2024 常见漏洞扫描
    '\/owa\/auth\.aspx',
    '\/ecp\/',
    '\/ews\/exchange\.asmx',
    '\/autodiscover\/autodiscover\.xml',
    '\/\.aws\/credentials',
    '\/\.ssh\/id_rsa',
    '\/\.ssh\/authorized_keys',
    '\/\.docker\/config\.json',
    '\/\.kube\/config',
    '\/\.npmrc',
    '\/\.pypirc',
    '\/\.gem\/credentials',
    '\/composer\.json',
    '\/package\.json',
    '\/yarn\.lock',
    '\/go\.mod',
    '\/Cargo\.toml',
    '\/pom\.xml',
    '\/build\.gradle',
    '\/requirements\.txt',
    '\/Gemfile',
    '\/mix\.exs',
    '\/Podfile',
    
    # 数据库扫描
    '\/phpmyadmin',
    '\/pma',
    '\/mysql\/',
    '\/mongo\/',
    '\/redis\/',
    '\/elasticsearch\/',
    '\/cassandra\/',
    '\/clickhouse\/',
    '\/influxdb\/',
    
    # API 安全
    '\/api\/keys',
    '\/api\/secrets',
    '\/api\/tokens',
    '\/api\/users',
    '\/api\/admin',
    '\/api\/config',
    '\/api\/settings',
    '\/api\/backup',
    '\/api\/export',
    '\/api\/import',
    
    # 后门和 Webshell
    '\/shell\.php',
    '\/cmd\.php',
    '\/eval\.php',
    '\/system\.php',
    '\/exec\.php',
    '\/webshell',
    '\/backdoor',
    '\/\.webshell',
    '\/\.backdoor',
    '\/c99\.php',
    '\/r57\.php',
    '\/b374k',
    '\/wso\.php',
    '\/china\.php',
    '\/chopper\.asp',
    '\/caidao\.php',
    
    # SQL 注入特征
    '\'\+union\+select',
    '\'\+and\+1=1',
    '\'\+or\+1=1',
    '\%27\%20union\%20select',
    '\%27\%20and\%201=1',
    '\%27\%20or\%201=1',
    '\/sqlmap\/',
    
    # XSS 尝试
    '\%3Cscript\%3E',
    '\%3Cimg\%20src\%3D',
    'javascript:alert',
    'onerror=alert',
    'onload=alert',
    
    # 命令注入
    ';\+cat\+',
    ';\+ls\+',
    ';\+pwd\+',
    ';\+id\+',
    ';\+whoami\+',
    ';\+uname\+',
    '\|cat\|',
    '\|ls\|',
    '\|pwd\|',
    '\|id\|',
    '\|whoami\|',
    
    # SSRF 尝试
    '\/localhost',
    '\/127\.0\.0\.1',
    '\/169\.254\.169\.254',
    '\/metadata\/',
    '\/latest\/meta-data\/',
    
    # XXE 尝试
    '<!ENTITY',
    '\%26xxe\%3B',
    'xml\+external\+entity',
    
    # 路径遍历
    '\.\.\/\.\.\/',
    '\.\.\\\.\.\\',
    '\%2e\%2e\%2f',
    '\%2e\%2e\%5c',
    
    # 旧蠕虫（保留兼容）
    '\/default\.ida',
    '\/null\.idq',
    'exe\?\/c\+dir',
    'root\.exe',
    'admin\.dll',
    '\/nsiislog\.dll',
    '\/sumthin',
    '\/winnt\/system32\/cmd\.exe',
    '\/_vti_inf\.html',
    '\/_vti_bin\/shtml\.exe\/_vti_rpc'
);

# WormsHashID
#-----------------------------------------------------------------------------
%WormsHashID = (
    '\/wp-admin\/admin-ajax\.php.*wp_rest', 'wp_rest_attack',
    '\/\.env', 'env_leak_scanner',
    '\/\.git\/config', 'git_leak_scanner',
    '\/api\/v1\/auth', 'api_auth_scanner',
    '\/actuator\/health', 'spring_actuator_scanner',
    '\/actuator\/env', 'spring_actuator_scanner',
    '\/actuator\/gateway', 'spring_actuator_scanner',
    '\/console\/', 'console_scanner',
    '\/solr\/admin', 'solr_scanner',
    '\/jmx-console', 'jmx_scanner',
    '\/invoker\/JMXInvokerServlet', 'jmx_scanner',
    '\/druid\/index.html', 'druid_scanner',
    '\/swagger-ui\.html', 'api_discovery',
    '\/v2\/_catalog', 'docker_registry_scanner',
    '\/_nodes\/stats', 'elasticsearch_scanner',
    '\/_search', 'elasticsearch_scanner',
    '\/_sql', 'elasticsearch_scanner',
    '\/api\/graphql', 'graphql_scanner',
    '\/graphql', 'graphql_scanner',
    '\/v1\/graphql', 'graphql_scanner',
    
    # Log4j
    '\$\{jndi:', 'log4shell',
    '\$\{env:', 'log4shell',
    '\$\{sys:', 'log4shell',
    '\$\{java:', 'log4shell',
    '\$\{main:', 'log4shell',
    '\$\{log4j:', 'log4shell',
    
    # Spring4Shell
    '\/spring-framework\/.*class\.module', 'spring4shell',
    '\/web\/.*class\.module', 'spring4shell',
    '\/\.\..\/\.\.\/WEB-INF', 'spring4shell',
    
    # 勒索软件
    '\/\.wannacry', 'wannacry',
    '\/\.badrabbit', 'badrabbit',
    '\/\.petya', 'petya',
    '\/\.locky', 'locky',
    '\/\.cerber', 'cerber',
    '\/\.ryuk', 'ryuk',
    '\/\.revil', 'revil',
    '\/\.darkSide', 'darkside',
    
    # 配置文件泄露
    '\/\.aws\/credentials', 'aws_cred_leak',
    '\/\.ssh\/id_rsa', 'ssh_key_leak',
    '\/\.ssh\/authorized_keys', 'ssh_key_leak',
    '\/\.docker\/config\.json', 'docker_cred_leak',
    '\/\.kube\/config', 'kube_config_leak',
    '\/\.npmrc', 'npm_token_leak',
    '\/\.pypirc', 'pypi_cred_leak',
    '\/\.gem\/credentials', 'rubygems_cred_leak',
    
    # Webshell
    '\/shell\.php', 'webshell',
    '\/cmd\.php', 'webshell',
    '\/eval\.php', 'webshell',
    '\/system\.php', 'webshell',
    '\/exec\.php', 'webshell',
    '\/webshell', 'webshell',
    '\/backdoor', 'backdoor',
    '\/\.webshell', 'webshell',
    '\/\.backdoor', 'backdoor',
    '\/c99\.php', 'c99_webshell',
    '\/r57\.php', 'r57_webshell',
    '\/b374k', 'b374k_webshell',
    '\/wso\.php', 'wso_webshell',
    '\/china\.php', 'china_webshell',
    '\/chopper\.asp', 'china_webshell',
    '\/caidao\.php', 'china_webshell',
    
    # 旧蠕虫
    '\/default\.ida', 'code_red',
    '\/null\.idq', 'code_red',
    'exe\?\/c\+dir', 'nimda',
    'root\.exe', 'nimda',
    'admin\.dll', 'nimda',
    '\/nsiislog\.dll', 'mpex',
    '\/sumthin', 'sumthin',
    '\/winnt\/system32\/cmd\.exe', 'nimda',
    '\/_vti_inf\.html', 'unknown',
    '\/_vti_bin\/shtml\.exe\/_vti_rpc', 'unknown'
);

# WormsHashLib - 蠕虫显示名称
#-----------------------------------------------------------------------------
%WormsHashLib = (
    # 2020-2026
    'wp_rest_attack', 'WordPress REST API attack',
    'env_leak_scanner', '.env file leak scanner',
    'git_leak_scanner', 'Git repository leak scanner',
    'api_auth_scanner', 'API authentication scanner',
    'spring_actuator_scanner', 'Spring Boot Actuator scanner',
    'console_scanner', 'Application console scanner',
    'solr_scanner', 'Apache Solr scanner',
    'jmx_scanner', 'JMX console scanner',
    'druid_scanner', 'Alibaba Druid scanner',
    'api_discovery', 'API discovery tool',
    'docker_registry_scanner', 'Docker registry scanner',
    'elasticsearch_scanner', 'Elasticsearch scanner',
    'graphql_scanner', 'GraphQL endpoint scanner',
    
    # Log4j
    'log4shell', 'Log4Shell (Log4j RCE) worm',
    
    # Spring4Shell
    'spring4shell', 'Spring4Shell (Spring RCE) worm',
    
    # 勒索软件
    'wannacry', 'WannaCry ransomware worm',
    'badrabbit', 'BadRabbit ransomware worm',
    'petya', 'Petya/NotPetya ransomware worm',
    'locky', 'Locky ransomware worm',
    'cerber', 'Cerber ransomware worm',
    'ryuk', 'Ryuk ransomware worm',
    'revil', 'REvil/Sodinokibi ransomware worm',
    'darkside', 'DarkSide ransomware worm',
    
    # 凭据泄露
    'aws_cred_leak', 'AWS credentials leak scanner',
    'ssh_key_leak', 'SSH key leak scanner',
    'docker_cred_leak', 'Docker credentials leak scanner',
    'kube_config_leak', 'Kubernetes config leak scanner',
    'npm_token_leak', 'NPM token leak scanner',
    'pypi_cred_leak', 'PyPI credentials leak scanner',
    'rubygems_cred_leak', 'RubyGems credentials leak scanner',
    
    # Webshell
    'webshell', 'Webshell backdoor',
    'backdoor', 'Backdoor access',
    'c99_webshell', 'C99 Webshell',
    'r57_webshell', 'R57 Webshell',
    'b374k_webshell', 'b374k Webshell',
    'wso_webshell', 'WSO Webshell',
    'china_webshell', 'China Chopper webshell',
    
    # 旧蠕虫
    'code_red', 'Code Red family worm',
    'mpex', 'IIS Exploit worm',
    'nimda', 'Nimda family worm',
    'sumthin', 'Sumthin worm',
    'unknown', 'Unknown worm'
);

# WormsHashTarget - 蠕虫攻击目标
#-----------------------------------------------------------------------------
%WormsHashTarget = (
    # 2020-2026
    'wp_rest_attack', 'WordPress',
    'env_leak_scanner', 'Web applications',
    'git_leak_scanner', 'Web applications',
    'api_auth_scanner', 'API endpoints',
    'spring_actuator_scanner', 'Spring Boot applications',
    'console_scanner', 'Web applications',
    'solr_scanner', 'Apache Solr',
    'jmx_scanner', 'Java JMX console',
    'druid_scanner', 'Alibaba Druid',
    'api_discovery', 'API endpoints',
    'docker_registry_scanner', 'Docker Registry',
    'elasticsearch_scanner', 'Elasticsearch',
    'graphql_scanner', 'GraphQL endpoints',
    'log4shell', 'Java applications using Log4j 2.x',
    'spring4shell', 'Spring Framework applications',
    'wannacry', 'Windows SMBv1',
    'badrabbit', 'Windows systems',
    'petya', 'Windows systems',
    'locky', 'Windows systems',
    'cerber', 'Windows systems',
    'ryuk', 'Windows systems',
    'revil', 'Windows/Linux systems',
    'darkside', 'Windows systems',
    'aws_cred_leak', 'AWS services',
    'ssh_key_leak', 'SSH servers',
    'docker_cred_leak', 'Docker containers',
    'kube_config_leak', 'Kubernetes clusters',
    'npm_token_leak', 'NPM registry',
    'pypi_cred_leak', 'PyPI registry',
    'rubygems_cred_leak', 'RubyGems registry',
    'webshell', 'Web servers',
    'backdoor', 'Web servers',
    'c99_webshell', 'PHP web servers',
    'r57_webshell', 'PHP web servers',
    'b374k_webshell', 'PHP web servers',
    'wso_webshell', 'PHP web servers',
    'china_webshell', 'ASP/PHP web servers',
    'code_red', 'IIS',
    'mpex', 'IIS',
    'nimda', 'IIS',
    'sumthin', 'Unknown',
    'unknown', 'MS products'
);

1;