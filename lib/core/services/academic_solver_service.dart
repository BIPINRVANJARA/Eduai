class AcademicSolverService {
  static String? solveAssignmentQuestion({
    required String userText,
    required String activeSubject,
    required String activeDocumentTitle,
    required String language, // 'ENGLISH' | 'GUJARATI' | 'HINDI'
  }) {
    final lower = userText.toLowerCase();
    final docLower = '$activeSubject $activeDocumentTitle'.toLowerCase();

    // Extract Question Number (e.g. "que 1", "question 2", "1st que", "q1", "1")
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
      return _solveAipdQuestion(questionNumber, language);
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
  // 1. FUNDAMENTALS OF BLOCKCHAIN (FBC)
  // =========================================================================
  static String _solveFbcQuestion(int qNum, String lang, String docTitle) {
    if (lang == 'GUJARATI') {
      switch (qNum) {
        case 1:
          return '''### 📝 પ્રશ્ન ૧: બ્લોકચેન ટેકનોલોજી એટલે શું? તેનું આર્કિટેક્ચર અને DLT સમજાવો.

**૧. બ્લોકચેનની વ્યાખ્યા:**
બ્લોકચેન એ એક ડિસ્ટ્રિબ્યુટેડ, ડીસેન્ટ્રલાઇઝ્ડ અને ઇમ્યુટેબલ (અપરિવર્તનીય) ડિજિટલ લેજર (Digital Ledger) છે, જેમાં ડેટા ક્રિપ્ટોગ્રાફિક હેશિંગ દ્વારા જોડાયેલા બ્લોક્સની શૃંખલામાં સુરક્ષિત રીતે સંગ્રહિત થાય છે.

**૨. બ્લોકચેન આર્કિટેક્ચરના મુખ્ય ઘટકો:**
• **બ્લોક હેડર (Block Header):**
  - **Previous Block Hash:** પાછલા બ્લોકનો 256-બીટ હેશ કોડ.
  - **Merkle Root Hash:** બ્લોકમાં રહેલા તમામ ટ્રાન્ઝેક્શન્સનો ક્રિપ્ટોગ્રાફિક સારાંશ.
  - **Timestamp:** બ્લોક ક્યારે બન્યો તેનો ચોક્કસ સમય.
  - **Nonce (Number used Once):** Proof-of-Work માટેનો રેન્ડમ નંબર.
• **ટ્રાન્ઝેક્શન ડેટા (Transaction Data):** માન્ય ડિજિટલ ટ્રાન્ઝેક્શન્સની યાદી.

**૩. DLT વિરુદ્ધ સેન્ટ્રલાઈઝ્ડ ડેટાબેઝ:**
| લક્ષણ | સેન્ટ્રલાઈઝ્ડ ડેટાબેઝ | ડિસ્ટ્રિબ્યુટેડ લેજર (DLT) |
| :--- | :--- | :--- |
| કંટ્રોલ | સિંગલ એડમિનિસ્ટ્રેટર | સમગ્ર નેટવર્ક (P2P Nodes) |
| વિશ્વસનીયતા | સિંગલ પોઈન્ટ ઓફ ફેલ્યર | ઉચ્ચ ફોલ્ટ ટોલરન્સ |
| પારદર્શિતા | સીમિત | સંપૂર્ણ પારદર્શક અને વેરિફાયેબલ |

**૪. સારાંશ:**
બ્લોકચેનમાં મધ્યસ્થી વિના સુરક્ષિત, પારદર્શક અને કાયમી ટ્રાન્ઝેક્શન થાય છે.''';

        case 2:
          return '''### 📝 પ્રશ્ન ૨: Consensus Mechanisms: Proof of Work (PoW) vs Proof of Stake (PoS).

**૧. કન્સેન્સસ મિકેનિઝમ એટલે શું?**
ડીસેન્ટ્રલાઈઝ્ડ નેટવર્કના તમામ નોડ્સ એક જ લેજર સ્ટેટ પર સહમત થાય તે પ્રક્રિયાને કન્સેન્સસ કહેવાય છે.

**૨. Proof of Work (PoW) વિરુદ્ધ Proof of Stake (PoS):**
• **Proof of Work (PoW):**
  - માઇનર્સ જટિલ ગણિતિક કોયડા ઉકેલે છે.
  - ઉદાહરણ: Bitcoin.
  - ગેરફાયદો: ભારે વીજ વપરાશ.
• **Proof of Stake (PoS):**
  - વેલિડેટર્સ તેમના કોઈન્સને નેટવર્કમાં 'સ્ટેક' કરીને નવા બ્લોક ચકાસે છે.
  - ઉદાહરણ: Ethereum 2.0, Cardano.
  - ફાયદો: ૯૯.૯% ઓછી ઊર્જા વપરાશ અને ઝડપી ટ્રાન્ઝેક્શન.

**૩. પરીક્ષા ઉપયોગી મુદ્દા:**
PoS વધુ ઇકો-ફ્રેન્ડલી અને સ્કેલેબલ છે, જ્યારે PoW સૌથી જૂનું અને સુરક્ષિત માનવામાં આવે છે.''';

        default:
          return '''### 📝 પ્રશ્ન $qNum: Fundamentals of Blockchain (FBC)

**૧. મુખ્ય સિદ્ધાંત:**
બ્લોકચેન નેટવર્કમાં ક્રિપ્ટોગ્રાફિક હેશ (SHA-256), પબ્લિક-પ્રાઇવેટ કી પેર અને સ્માર્ટ કોન્ટ્રાક્ટ્સ દ્વારા ડેટા સિક્યોરિટી સુનિશ્ચિત કરવામાં આવે છે.

**૨. સ્માર્ટ કોન્ટ્રાક્ટ્સ અને EVM:**
• સ્માર્ટ કોન્ટ્રાક્ટ્સ એ સેલ્ફ-એક્ઝિક્યુટિંગ કોડ છે જે શરતો પૂર્ણ થતાં આપોઆપ રન થાય છે.
• સોલિડિટી (Solidity) પ્રોગ્રામિંગ ભાષા દ્વારા Ethereum નેટવર્ક પર સ્માર્ટ કોન્ટ્રાક્ટ્સ લખાય છે.

**૩. ઉપયોગો:**
Supply Chain Management, Decentralized Finance (DeFi), Digital Identity, અને Voting Systems.''';
      }
    }

    // ENGLISH (Default)
    switch (qNum) {
      case 1:
        return '''### 📝 Question 1: What is Blockchain Technology? Explain Blockchain Architecture and DLT vs Centralized Database.

**1. Definition of Blockchain:**
A **Blockchain** is a decentralized, distributed, and immutable digital ledger that cryptographically links sequential blocks containing verified transaction data across a peer-to-peer (P2P) network.

**2. Blockchain Core Architecture & Block Anatomy:**
Every block consists of two primary segments:
• **Block Header:**
  - **Previous Block Hash (PrevHash):** 256-bit SHA-256 hash pointer linking back to the parent block, ensuring unbroken chain integrity.
  - **Merkle Root Hash:** The cryptographic root hash of all transactions in the block (Merkle Tree).
  - **Timestamp:** The exact UTC time the block was mined/validated.
  - **Nonce (Number used Once):** A 32-bit integer altered by miners to satisfy the Proof-of-Work difficulty target.
  - **Difficulty Target:** Network mining difficulty.
• **Block Body:**
  - The ordered ledger list of verified digital transactions (Tx1, Tx2, ... TxN).

**3. Comparison: Centralized Database vs Distributed Ledger Technology (DLT):**
| Metric | Centralized Database (SQL/Oracle) | Distributed Ledger (Blockchain) |
| :--- | :--- | :--- |
| **Authority** | Single DBA / Organization | Decentralized Consensus (P2P Nodes) |
| **Immutability** | Data can be altered or deleted | Write-Once, Append-Only (Immutable) |
| **Security** | Single Point of Failure (SPOF) | Cryptographic Hashing & Fault Tolerant |
| **Transparency** | Restricted to admin users | Verifiable by all participating nodes |

**4. Key Exam Takeaway:**
Blockchain eliminates the need for trusted central intermediaries by replacing institutional trust with mathematical and cryptographic proof.''';

      case 2:
        return '''### 📝 Question 2: Explain Consensus Mechanisms: Proof of Work (PoW) vs Proof of Stake (PoS).

**1. What is a Consensus Mechanism?**
A consensus mechanism is a fault-tolerant protocol used in distributed blockchain networks to achieve single-state agreement among distrusting peer nodes.

**2. Proof of Work (PoW):**
• **Working Principle:** Miners expend vast computational hash-power solving complex cryptographic puzzles (finding a hash with required leading zeros).
• **Security:** 51% Attack resistant due to colossal hardware capital cost.
• **Drawbacks:** Immense electrical energy consumption and limited transaction throughput (~7 TPS in Bitcoin).

**3. Proof of Stake (PoS):**
• **Working Principle:** Validators lock up (stake) native cryptocurrency tokens as collateral to propose and validate new blocks.
• **Security:** Malicious actors face slashing penalties (loss of staked assets).
• **Advantages:** >99.9% energy reduction, faster block confirmation, and higher scalability (Ethereum 2.0, Solana).

**4. Comparison Summary:**
PoW rewards hardware computational capability, whereas PoS rewards economic stake and network reliability.''';

      case 3:
        return '''### 📝 Question 3: Explain Cryptography in Blockchain: SHA-256, Asymmetric Key Pairs, and Digital Signatures.

**1. Cryptographic Hash Functions (SHA-256):**
• Takes arbitrary length input and produces a fixed 256-bit output.
• **Properties:** Deterministic, Avalanche Effect (minor input change alters output completely), and Pre-image Resistance (one-way function).

**2. Asymmetric Public-Private Key Cryptography:**
• **Private Key:** Secret key kept safely by the wallet owner; used to sign transactions.
• **Public Key:** Mathematically derived from the private key via Elliptic Curve Cryptography (ECDSA/secp256k1); shared publicly as the wallet address.

**3. Digital Signatures:**
• **Signing:** Transaction data + Private Key -> Digital Signature.
• **Verification:** Anyone on the network verifies authenticity using the Public Key without exposing the Private Key.''';

      case 4:
        return '''### 📝 Question 4: What are Smart Contracts? Explain their Execution Environment and Lifecycle.

**1. Definition of Smart Contract:**
A smart contract is self-executing deterministic code stored on the blockchain that automatically enforces contract clauses when predetermined conditions are met.

**2. Key Characteristics:**
• **Deterministic:** Executes the exact same output given identical inputs across all nodes.
• **Immutable:** Once deployed to mainnet, the code cannot be tampered with.
• **Autonomous:** Executes without human intermediaries or third-party escrow.

**3. Execution Environment:**
• Smart contracts run on the **Ethereum Virtual Machine (EVM)** using bytecode compiled from high-level languages like **Solidity** or **Vyper**.
• **Gas:** Computational fee paid in gwei to miners/validators to prevent infinite loops and denial-of-service attacks.''';

      case 5:
        return '''### 📝 Question 5: What is a Merkle Tree? Explain its Construction and Verification.

**1. Merkle Tree Concept:**
A **Merkle Tree** (Binary Hash Tree) is a data structure used to efficiently summarize and verify the integrity of large datasets in a block.

**2. Construction Process:**
• Every transaction is hashed individually: HA = SHA256(TxA).
• Consecutive pairs of hashes are concatenated and hashed together: HAB = SHA256(HA + HB).
• The process continues upward until a single root hash remains: the **Merkle Root**.

**3. Advantage:**
Enables **Simple Payment Verification (SPV)** where a light node can verify if a transaction exists in a block with logarithmic O(log N) proof complexity rather than downloading the entire ledger.''';

      default:
        return '''### 📝 Question $qNum: Fundamentals of Blockchain (FBC)

**1. Topic Overview:**
In Unit $qNum of Fundamentals of Blockchain (FBC), core concepts include Distributed Ledger Architecture, Cryptographic Hashing, Decentralized Consensus, and Smart Contract deployment.

**2. Essential Architectural Points:**
• P2P Network Synchronization & Byzantine Fault Tolerance (BFT).
• Public vs Private Permissioned Blockchains (e.g. Ethereum vs Hyperledger Fabric).
• Real-world applications in Decentralized Identity, Supply Chain traceability, and Central Bank Digital Currencies (CBDC).

**3. Academic Solution Summary:**
Review the GTU syllabus unit requirements for $docTitle. If you need step-by-step code in Solidity or cryptographic hash calculations, specify "show Solidity code" or "explain SHA-256 steps".''';
    }
  }

  // =========================================================================
  // 2. ARTIFICIAL INTELLIGENCE & PRODUCT DEVELOPMENT (AIPD)
  // =========================================================================
  static String _solveAipdQuestion(int qNum, String lang) {
    switch (qNum) {
      case 1:
        return '''### 📝 Question 1: Define Artificial Intelligence and explain AI Agent Architecture & PEAS Framework.

**1. Definition of Artificial Intelligence:**
Artificial Intelligence (AI) is the science of designing computational systems that can perform tasks normally requiring human intelligence—including reasoning, perception, learning, and decision making.

**2. Rational Agents & Environment:**
An AI Agent perceives its environment through **Sensors** and acts upon it using **Actuators**.

**3. The PEAS Framework:**
• **Performance Measure:** The metric used to evaluate agent success (e.g. Safety, Speed, Accuracy).
• **Environment:** The operational domain (e.g. City roads, Chess board, Hospital records).
• **Actuators:** Output mechanisms to execute actions (e.g. Steering wheel, Display screen, Robotic arm).
• **Sensors:** Input devices (e.g. Cameras, Sonar, Keyboard input).

**4. Example (Autonomous Taxi):**
• **P:** Fast, legal, comfortable trip, maximized profit.
• **E:** Roads, vehicular traffic, pedestrians, weather conditions.
• **A:** Steering, accelerator, brake, horn, display.
• **S:** Cameras, LiDAR, GPS, speedometer, odometer.''';

      case 2:
        return '''### 📝 Question 2: Explain Search Algorithms in AI: Uninformed vs Informed (Heuristic) Search.

**1. Uninformed (Blind) Search:**
• Explores state space without domain-specific knowledge of goal proximity.
• **Breadth-First Search (BFS):** Explores level-by-level; complete and optimal for unweighted graphs; space complexity O(b^d).
• **Depth-First Search (DFS):** Explores deepest node first; low memory O(bm), but not guaranteed optimal.

**2. Informed (Heuristic) Search:**
• Uses evaluation function f(n) = g(n) + h(n) to guide search toward the goal.
• **A* Search:** Combines actual path cost g(n) and estimated heuristic cost h(n).
• Guaranteed complete and optimal if h(n) is **admissible** (never overestimates true cost) and **consistent**.''';

      default:
        return '''### 📝 Question $qNum: Artificial Intelligence & Product Development (AIPD)

**1. Core Topic:**
Unit $qNum of AIPD focuses on AI system lifecycle, model training workflows, feature engineering, and deploying machine learning pipelines into production software products.

**2. Key Architecture:**
• Data Pipeline -> Feature Extraction -> Model Training -> Evaluation & Validation -> Inference API / Edge Deployment.
• Performance Monitoring against Data Drift and Concept Drift in live production.''';
    }
  }

  // =========================================================================
  // 3. ARTIFICIAL INTELLIGENCE & PROMPT ENGINEERING (AIPE)
  // =========================================================================
  static String _solveAipeQuestion(int qNum, String lang) {
    return '''### 📝 Question $qNum: Artificial Intelligence & Prompt Engineering (AIPE)

**1. Prompting Frameworks:**
• **Zero-Shot Prompting:** Providing direct instruction without demonstration examples.
• **Few-Shot Prompting:** Supplying 2-5 input-output demonstration pairs to condition the model output format.
• **Chain-of-Thought (CoT):** Asking the model to "think step by step" to decompose complex reasoning tasks.

**2. LLM Hyperparameters:**
• **Temperature (0.0 to 1.0):** Lower values produce deterministic, factual answers; higher values increase randomness and creativity.
• **Top-P (Nucleus Sampling):** Selects tokens from the smallest cumulative probability mass.''';
  }

  // =========================================================================
  // 4. OTHER SUBJECTS (DBMS, CN, OS, GENERIC)
  // =========================================================================
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
• **Exam Tips:** Focus on standard definitions, clean bullet points, and practical examples for full marks.''';
  }
}
