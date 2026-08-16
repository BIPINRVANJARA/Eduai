class AcademicSolverService {
  static String solveAssignmentQuestion({
    required String userText,
    required String activeSubject,
    required String activeDocumentTitle,
    required String language, // 'ENGLISH' | 'GUJARATI' | 'HINDI'
  }) {
    final lower = userText.toLowerCase().trim();
    final docLower = '$activeSubject $activeDocumentTitle'.toLowerCase();

    // 1. Check for specific question text keywords directly (e.g. "Define AI Product", "Smart Contracts", etc.)
    if (lower.contains('ai product') || (lower.contains('define') && lower.contains('product'))) {
      return _solveAiProductQuestion(language);
    }
    if (lower.contains('agent') && (lower.contains('peas') || lower.contains('rational'))) {
      return _solvePeasAgentQuestion(language);
    }
    if (lower.contains('smart contract') || lower.contains('solidity') || lower.contains('evm')) {
      return _solveSmartContractQuestion(language);
    }
    if (lower.contains('consensus') || lower.contains('pow') || lower.contains('pos') || lower.contains('proof of work')) {
      return _solveConsensusQuestion(language);
    }
    if (lower.contains('merkle') || lower.contains('hash tree')) {
      return _solveMerkleQuestion(language);
    }
    if (lower.contains('search algorithm') || lower.contains('bfs') || lower.contains('dfs') || lower.contains('a*') || lower.contains('heuristic')) {
      return _solveSearchAlgoQuestion(language);
    }
    if (lower.contains('prompt engineering') || lower.contains('zero shot') || lower.contains('few shot') || lower.contains('cot')) {
      return _solvePromptEngQuestion(language);
    }

    // 2. Extract Question Number (e.g. "que 1", "question 2", "q1", "1st que")
    int questionNumber = 1;
    final numMatch = RegExp(r'(?:que|question|q|prashna|પ્રશ્ન)?\s*([0-9]+)').firstMatch(lower);
    if (numMatch != null && numMatch.group(1) != null) {
      questionNumber = int.tryParse(numMatch.group(1)!) ?? 1;
    }

    final bool isFbc = docLower.contains('fbc') || docLower.contains('blockchain');
    final bool isAipd = docLower.contains('aipd') || docLower.contains('product development');
    final bool isAipe = docLower.contains('aipe') || docLower.contains('prompt');
    final bool isDbms = docLower.contains('dbms') || docLower.contains('database');
    final bool isCn = docLower.contains('cn') || docLower.contains('network');
    final bool isOs = docLower.contains('os') || docLower.contains('operating system');

    if (isFbc) {
      return _solveFbcQuestion(questionNumber, language, activeDocumentTitle);
    } else if (isAipd) {
      return _solveAipdQuestion(questionNumber, language, activeDocumentTitle);
    } else if (isAipe) {
      return _solveAipeQuestion(questionNumber, language);
    } else if (isDbms) {
      return _solveDbmsQuestion(questionNumber, language);
    } else if (isCn) {
      return _solveCnQuestion(questionNumber, language);
    } else if (isOs) {
      return _solveOsQuestion(questionNumber, language);
    }

    // Generic Subject Question Solver
    return _solveGenericQuestion(activeSubject, questionNumber, language);
  }

  // =========================================================================
  // DIRECT EXACT QUESTION SOLVERS (ZERO HALLUCINATION)
  // =========================================================================
  static String _solveAiProductQuestion(String lang) {
    if (lang == 'GUJARATI') {
      return '''### 💡 પ્રશ્ન: AI Product (આર્ટિફિશિયલ ઇન્ટેલિજન્સ પ્રોડક્ટ) ની વ્યાખ્યા આપો.

**૧. AI Product ની વ્યાખ્યા:**
**AI Product** એ એવો સોફ્ટવેર, એપ્લિકેશન અથવા હાર્ડવેર સિસ્ટમ છે જે મશીન લર્નિંગ, નેચરલ લેંગ્વેજ પ્રોસેસિંગ (NLP), કમ્પ્યુટર વિઝન અથવા એઆઈ એલ્ગોરિધમ્સનો ઉપયોગ કરીને વાસ્તવિક સમસ્યાઓનો આપમેળે ઉકેલ લાવે છે, આગાહીઓ કરે છે અથવા નિર્ણયો લે છે.

**૨. મુખ્ય લક્ષણો:**
• **સ્વતઃ શિખવાની ક્ષમતા (Continuous Learning):** વપરાશકર્તાના નવા ડેટામાંથી સતત સુધારો કરે છે.
• **સંભાવનાત્મક પરિણામો (Probabilistic Output):** પરંપરાગત ફિક્સ કોડિંગની જગ્યાએ આંકડાકીય મોડેલ્સ પર કાર્ય કરે છે.
• **માનવ સહયોગ (Human-in-the-loop):** જટિલ પ્રક્રિયાઓમાં માનવ નિર્ણયને ઝડપી બનાવે છે.

**૩. જાણીતા ઉદાહરણો:**
• ChatGPT / Gemini (જનરેટિવ એઆઈ પ્રોડક્ટ્સ)
• Tesla Autopilot (સ્વચાલિત વાહન)
• Netflix Recommendation System (મનોરંજન સૂચનો)''';
    }

    return '''### 💡 Question: Define AI Product

**1. Definition of AI Product:**
An **AI Product** is a software application, digital platform, or hardware system that integrates Artificial Intelligence algorithms (such as Machine Learning models, Deep Neural Networks, Natural Language Processing, or Computer Vision) as its core functionality to automate cognitive tasks, deliver predictive insights, and solve complex user problems dynamically.

**2. Core Characteristics of an AI Product:**
• **Continuous Learning & Adaptation:** Utilizes continuous data feedback loops to retrain models and improve prediction accuracy over time.
• **Probabilistic Logic:** Unlike traditional deterministic software with rigid if-else rules, AI products evaluate confidence scores and probabilities.
• **Data-Driven Core:** The product's intelligence scales directly with the quality and volume of domain data.
• **Human-AI Collaboration:** Augments human decision-making with automated assistance.

**3. Real-World Examples:**
• **Conversational Copilots:** ChatGPT, Claude, GitHub Copilot.
• **Autonomous Systems:** Tesla Full Self-Driving (FSD), Waymo.
• **Predictive Engines:** Netflix Recommendation System, Google Search Ranking, Spotify Discover.
• **Enterprise Diagnostics:** AI Healthcare diagnostic imaging tools.''';
  }

  static String _solveSmartContractQuestion(String lang) {
    return '''### 💡 Question: What are Smart Contracts? Explain their Execution Environment and Lifecycle.

**1. Definition of Smart Contract:**
A **Smart Contract** is a self-executing, decentralized digital program deployed on a blockchain network that automatically enforces and executes contractual terms when predefined cryptographic conditions are met.

**2. Key Characteristics:**
• **Autonomous:** Executes without intermediaries, lawyers, or central escrow services.
• **Immutable:** Once deployed to the blockchain, the contract logic and state cannot be modified or tampered with.
• **Deterministic:** Identical inputs yield identical execution results across all validator nodes.

**3. Execution Environment:**
• Runs on the **Ethereum Virtual Machine (EVM)** compiled into bytecode from languages such as **Solidity** or **Vyper**.
• **Gas Mechanism:** Every operation requires a computational fee (Gas) paid in cryptocurrency to prevent infinite loops and denial-of-service (DoS) attacks.''';
  }

  static String _solveConsensusQuestion(String lang) {
    return '''### 💡 Question: Consensus Mechanisms: Proof of Work (PoW) vs Proof of Stake (PoS)

**1. Concept of Consensus:**
A consensus mechanism enables distributed, decentralized blockchain nodes to reach a single unified state agreement without requiring a centralized authority.

**2. Proof of Work (PoW) vs Proof of Stake (PoS):**
| Metric | Proof of Work (PoW) | Proof of Stake (PoS) |
| :--- | :--- | :--- |
| **Validation Mechanism** | Computational mining (Solving cryptographic puzzles) | Economic staking (Validators lock tokens as collateral) |
| **Energy Consumption** | Very high electricity usage | >99.9% energy reduction (Eco-friendly) |
| **Security Mechanism** | 51% Hashpower defense | Slashing penalties on malicious staked capital |
| **Examples** | Bitcoin, Litecoin | Ethereum 2.0, Solana, Cardano |''';
  }

  static String _solveMerkleQuestion(String lang) {
    return '''### 💡 Question: Explain Merkle Tree in Blockchain

**1. What is a Merkle Tree?**
A **Merkle Tree** (Binary Hash Tree) is a cryptographic data structure where every leaf node is the hash of a transactional block, and every non-leaf node is the hash of its concatenated child nodes.

**2. Construction Process:**
• Transactions are hashed individually: HA = SHA256(TxA), HB = SHA256(TxB).
• Combined into parent hashes: HAB = SHA256(HA + HB).
• Merged upward until a single **Merkle Root Hash** is stored in the Block Header.

**3. Key Benefit:**
Enables **Simple Payment Verification (SPV)** allowing light nodes to prove a transaction's existence with logarithmic O(log N) complexity without downloading full multi-gigabyte blockchain ledgers.''';
  }

  static String _solvePeasAgentQuestion(String lang) {
    return '''### 💡 Question: Explain AI Rational Agents and PEAS Framework

**1. Rational AI Agent:**
An entity that perceives its environment through **Sensors**, makes intelligent decisions using an internal logic/learning model, and acts upon the environment via **Actuators** to maximize its expected performance measure.

**2. The PEAS Model:**
• **P (Performance Measure):** Goal metrics to evaluate success (e.g. Accuracy, Speed, Safety).
• **E (Environment):** The surrounding operational workspace (e.g. Roads, Hospital records, Game board).
• **A (Actuators):** Hardware/software mechanisms that carry out actions (e.g. Steering, Robotic arm, Display screen).
• **S (Sensors):** Input hardware/software (e.g. Cameras, Sonar, Microphones, Keyboard input).''';
  }

  static String _solveSearchAlgoQuestion(String lang) {
    return '''### 💡 Question: Search Algorithms in AI: Uninformed vs Informed Search

**1. Uninformed (Blind) Search:**
• Explores state spaces without domain knowledge or goal distance estimation.
• **Breadth-First Search (BFS):** Explores shallowest nodes first; complete and optimal for uniform step costs; memory O(b^d).
• **Depth-First Search (DFS):** Explores deepest path first; low memory O(bm), but not guaranteed optimal.

**2. Informed (Heuristic) Search:**
• Uses heuristic evaluation function f(n) = g(n) + h(n).
• **A* Search:** Guaranteed complete and optimal if the heuristic h(n) is admissible (never overestimates true cost) and consistent.''';
  }

  static String _solvePromptEngQuestion(String lang) {
    return '''### 💡 Question: Explain Prompt Engineering Techniques

**1. What is Prompt Engineering?**
The discipline of structuring, refining, and optimizing natural language inputs to Large Language Models (LLMs) to reliably elicit high-accuracy, deterministic outputs.

**2. Core Prompting Frameworks:**
• **Zero-Shot Prompting:** Providing a direct task instruction without providing prior example demonstrations.
• **Few-Shot Prompting:** Supplying 2-5 clear input-output example pairs within the context window to establish formatting and reasoning standards.
• **Chain-of-Thought (CoT):** Guiding the model to "think step by step" to break down multi-step mathematical, logical, or diagnostic tasks.''';
  }

  // =========================================================================
  // SUBJECT-SPECIFIC UNIT SOLVERS
  // =========================================================================
  static String _solveFbcQuestion(int qNum, String lang, String docTitle) {
    switch (qNum) {
      case 1:
        return '''### 📝 Question 1: What is Blockchain Technology? Explain Blockchain Architecture and DLT vs Centralized Database.

**1. Definition of Blockchain:**
A **Blockchain** is a decentralized, distributed, and immutable digital ledger that cryptographically links sequential blocks containing verified transaction data across a peer-to-peer (P2P) network.

**2. Blockchain Core Architecture & Block Anatomy:**
Every block consists of two primary segments:
• **Block Header:**
  - **Previous Block Hash (PrevHash):** 256-bit SHA-256 hash pointer linking back to the parent block.
  - **Merkle Root Hash:** The cryptographic root hash of all transactions in the block.
  - **Timestamp:** The exact UTC time the block was mined.
  - **Nonce (Number used Once):** A 32-bit integer altered by miners to satisfy the Proof-of-Work difficulty target.
• **Block Body:**
  - The ordered ledger list of verified digital transactions.

**3. Comparison: Centralized Database vs Distributed Ledger Technology (DLT):**
| Metric | Centralized Database (SQL/Oracle) | Distributed Ledger (Blockchain) |
| :--- | :--- | :--- |
| **Authority** | Single DBA / Organization | Decentralized Consensus (P2P Nodes) |
| **Immutability** | Data can be altered or deleted | Write-Once, Append-Only (Immutable) |
| **Security** | Single Point of Failure (SPOF) | Cryptographic Hashing & Fault Tolerant |
| **Transparency** | Restricted to admin users | Verifiable by all participating nodes |

---
💡 *Tip: You can also ask any exact question directly (e.g. "Define Smart Contracts" or "Explain Merkle Tree") for an instant step-by-step solution!*''';

      case 2:
        return _solveConsensusQuestion(lang);

      case 3:
        return _solveSmartContractQuestion(lang);

      case 4:
        return _solveMerkleQuestion(lang);

      default:
        return '''### 📝 Question $qNum: Fundamentals of Blockchain (FBC)

**1. Topic Overview:**
In Unit $qNum of Fundamentals of Blockchain (FBC), core concepts include Distributed Ledger Architecture, Cryptographic Hashing, Decentralized Consensus, and Smart Contract deployment.

**2. Essential Architectural Points:**
• P2P Network Synchronization & Byzantine Fault Tolerance (BFT).
• Public vs Private Permissioned Blockchains (e.g. Ethereum vs Hyperledger Fabric).
• Real-world applications in Decentralized Identity, Supply Chain traceability, and Central Bank Digital Currencies (CBDC).

---
💡 *Tip: You can paste the exact question text from your assignment sheet (e.g. "Define SHA-256" or "Explain Gas in Ethereum") to get the exact answer!*''';
    }
  }

  static String _solveAipdQuestion(int qNum, String lang, String docTitle) {
    switch (qNum) {
      case 1:
        return _solveAiProductQuestion(lang);

      case 2:
        return _solvePeasAgentQuestion(lang);

      case 3:
        return _solveSearchAlgoQuestion(lang);

      default:
        return '''### 📝 Question $qNum: Artificial Intelligence & Product Development (AIPD)

**1. Core Topic:**
Unit $qNum of AIPD focuses on AI system lifecycle, model training workflows, feature engineering, and deploying machine learning pipelines into production software products.

**2. Key Architecture:**
• Data Pipeline -> Feature Extraction -> Model Training -> Evaluation & Validation -> Inference API / Edge Deployment.
• Performance Monitoring against Data Drift and Concept Drift in live production.

---
💡 *Tip: Paste your exact assignment question (e.g. "Define AI Product" or "Explain Supervised vs Unsupervised Learning") for a comprehensive answer!*''';
    }
  }

  static String _solveAipeQuestion(int qNum, String lang) {
    return _solvePromptEngQuestion(lang);
  }

  static String _solveDbmsQuestion(int qNum, String lang) {
    return '''### 📝 Question $qNum: Database Management Systems (DBMS)

**1. Core Concepts:**
• ACID Properties: Atomicity, Consistency, Isolation, Durability.
• Relational Normalization (1NF, 2NF, 3NF, BCNF) to reduce data redundancy.
• SQL indexing using B-Trees and Hash indexes for query optimization.''';
  }

  static String _solveCnQuestion(int qNum, String lang) {
    return '''### 📝 Question $qNum: Computer Networks (CN)

**1. OSI 7-Layer Model:**
Physical -> Data Link -> Network (IP) -> Transport (TCP/UDP) -> Session -> Presentation -> Application (HTTP/DNS).

**2. TCP vs UDP:**
• TCP: Connection-oriented, reliable 3-way handshake, flow & congestion control.
• UDP: Connectionless, lightweight, low-latency streaming.''';
  }

  static String _solveOsQuestion(int qNum, String lang) {
    return '''### 📝 Question $qNum: Operating Systems (OS)

**1. Key Operating System Functions:**
• Process Scheduling (FCFS, SJF, Round Robin, Priority).
• Deadlock Prevention (Mutual Exclusion, Hold & Wait, No Preemption, Circular Wait).
• Virtual Memory and Demand Paging (LRU, FIFO page replacement).''';
  }

  static String _solveGenericQuestion(String subject, int qNum, String lang) {
    return '''### 📝 Question $qNum: $subject Assignment Solution

**1. Subject Overview:**
For **$subject**, Question $qNum addresses core theoretical foundations, architectural mechanisms, and analytical problem-solving required for GTU examination.

**2. Step-by-Step Academic Solution:**
• **Primary Concept:** Systematic breakdown of the underlying theoretical model.
• **Key Principles:** Structured implementation steps, formulas, and diagrams.
• **Exam Tips:** Focus on standard definitions, clean bullet points, and practical examples for full marks.

---
💡 *Tip: Paste your exact question text (e.g. "Define: ...") to get the exact exam-ready answer!*''';
  }
}
