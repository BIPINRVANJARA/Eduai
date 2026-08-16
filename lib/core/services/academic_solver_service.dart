class AcademicSolverService {
  static String solveAssignmentQuestion({
    required String userText,
    required String activeSubject,
    required String activeDocumentTitle,
    required String language, // 'ENGLISH' | 'GUJARATI' | 'HINDI'
  }) {
    final lower = userText.toLowerCase().trim();
    final docLower = '$activeSubject $activeDocumentTitle'.toLowerCase();

    // -----------------------------------------------------------------------
    // A. DIRECT KEYWORD MATCHING (Zero-Hallucination Exact Matching)
    // -----------------------------------------------------------------------
    if (lower.contains('bip-39') || lower.contains('bip39') || lower.contains('seed phrase') || lower.contains('mnemonic')) {
      return _solveBip39Question(language);
    }
    if (lower.contains('utxo') || lower.contains('unspent transaction')) {
      return _solveUtxoQuestion(language);
    }
    if (lower.contains('hot wallet') || lower.contains('cold wallet') || lower.contains('wallet')) {
      return _solveWalletQuestion(language);
    }
    if (lower.contains('halving') || lower.contains('block reward') || lower.contains('21 million') || lower.contains('capped at 21')) {
      return _solveHalvingQuestion(language);
    }
    if (lower.contains('transaction life cycle') || lower.contains('transaction lifecycle') || (lower.contains('bitcoin') && lower.contains('life cycle'))) {
      return _solveTxLifecycleQuestion(language);
    }
    if (lower.contains('fork') || lower.contains('soft fork') || lower.contains('hard fork')) {
      return _solveForksQuestion(language);
    }
    if (lower.contains('pow') && lower.contains('pos') || (lower.contains('proof of work') && lower.contains('proof of stake'))) {
      return _solveConsensusQuestion(language);
    }
    if (lower.contains('ai product') || (lower.contains('define') && lower.contains('product'))) {
      return _solveAiProductQuestion(language);
    }
    if (lower.contains('agent') && (lower.contains('peas') || lower.contains('rational'))) {
      return _solvePeasAgentQuestion(language);
    }
    if (lower.contains('smart contract') || lower.contains('solidity') || lower.contains('evm')) {
      return _solveSmartContractQuestion(language);
    }
    if (lower.contains('merkle') || lower.contains('hash tree')) {
      return _solveMerkleQuestion(language);
    }

    // -----------------------------------------------------------------------
    // B. EXTRACT QUESTION NUMBER & UNIT CONTEXT
    // -----------------------------------------------------------------------
    int questionNumber = 1;
    final numMatch = RegExp(r'(?:que|question|q|prashna|પ્રશ્ન)?\s*([0-9]+)').firstMatch(lower);
    if (numMatch != null && numMatch.group(1) != null) {
      questionNumber = int.tryParse(numMatch.group(1)!) ?? 1;
    }

    final bool isUnit2 = docLower.contains('assignment 2') || docLower.contains('assignment2') || docLower.contains('unit 2') || docLower.contains('unit-2') || lower.contains('assignment 2');
    final bool isFbc = docLower.contains('fbc') || docLower.contains('blockchain') || docLower.contains('foundation of blockchain');
    final bool isAipd = docLower.contains('aipd') || docLower.contains('product development');
    final bool isAipe = docLower.contains('aipe') || docLower.contains('prompt');
    final bool isDbms = docLower.contains('dbms') || docLower.contains('database');
    final bool isCn = docLower.contains('cn') || docLower.contains('network');
    final bool isOs = docLower.contains('os') || docLower.contains('operating system');

    if (isFbc) {
      if (isUnit2) {
        return _solveFbcUnit2Question(questionNumber, language);
      } else {
        return _solveFbcUnit1Question(questionNumber, language);
      }
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

    return _solveGenericQuestion(activeSubject, questionNumber, language);
  }

  // =========================================================================
  // FBC ASSIGNMENT 2 (UNIT-2) - OFFICIAL GTU QUESTIONS (GPH HIMMATNAGAR)
  // =========================================================================
  static String _solveFbcUnit2Question(int qNum, String lang) {
    switch (qNum) {
      case 1:
        return _solveWalletQuestion(lang);
      case 2:
        return _solveUtxoQuestion(lang);
      case 3:
        return _solveBip39Question(lang);
      case 4:
        return _solveHalvingQuestion(lang);
      case 5:
        return _solveTxLifecycleQuestion(lang);
      case 6:
        return _solveConsensusQuestion(lang);
      case 7:
        return _solveForksQuestion(lang);
      default:
        return '''### 📝 Question $qNum: Foundation of Blockchain (FBC) - Assignment 2 (Unit-2)

**Assignment 2 Questions:**
1. Differentiate between a hot wallet and a cold wallet.
2. Discuss the UTXO model with a simple numerical example.
3. Summarize the BIP-39 seed phrase generation process.
4. Describe the Bitcoin block reward system. Explain how halving works and why total supply is capped at 21 million.
5. Explain the complete Bitcoin transaction life cycle from creation to confirmation with diagram.
6. Compare Proof of Work and Proof of Stake.
7. Explain the concept of forks in blockchain (Soft Forks vs Hard Forks).''';
    }
  }

  // =========================================================================
  // INDIVIDUAL QUESTION SOLVERS
  // =========================================================================

  // Question 3: BIP-39 Seed Phrase Generation Process
  static String _solveBip39Question(String lang) {
    if (lang == 'GUJARATI') {
      return r'''### 📝 પ્રશ્ન ૩: BIP-39 સીડ ફ્રેઝ (Seed Phrase) જનરેશન પ્રક્રિયા સમજાવો.

**૧. BIP-39 એટલે શું?**
**BIP-39 (Bitcoin Improvement Proposal 39)** એ વપરાશકર્તા-મૈત્રીપૂર્ણ ૧૨ અથવા ૨૪ શબ્દોની યાદીમાંથી ડિટરમિનિસ્ટિક વૉલેટ સીડ (512-bit binary seed) જનરેટ કરવાની પ્રમાણિત પ્રક્રિયા છે.

**૨. સીડ ફ્રેઝ જનરેશનના પગલાં (Step-by-Step Process):**
1. **એન્ટ્રોપી જનરેશન (Entropy Generation):**
   - ૧૨૮ થી ૨૫૬ બીટ્સની ક્રિપ્ટોગ્રાફિક રેન્ડમ એન્ટ્રોપી (ENT) બનાવો (૧૨ શબ્દો માટે ૧૨૮-બીટ).
2. **ચેકસમ ગણતરી (Checksum Calculation):**
   - એન્ટ્રોપી પર **SHA-256** હેશિંગ લાગુ કરો.
   - હેશના પ્રથમ ENT / 32 બીટ્સને ચેકસમ (CS) તરીકે લો (૧૨૮-બીટ માટે ૪-બીટ ચેકસમ).
3. **ડેટા સંયોજન (Concatenation):**
   - એન્ટ્રોપી + ચેકસમ ભેગા કરો -> ૧૩૨ બીટ્સ (૧૨૮ + ૪).
4. **૧૧-બીટ ભાગોમાં વિભાજન (Split into 11-bit chunks):**
   - ૧૩૨ બીટ્સને ૧૧-૧૧ બીટ્સના ૧૨ ગ્રૂપમાં વિભાજિત કરો (132 / 11 = 12).
5. **વર્ડલિસ્ટ મેપિંગ (Wordlist Mapping):**
   - દરેક ૧૧-બીટ મૂલ્ય (0 થી 2047) ને સત્તાવાર BIP-39 શબ્દકોશના ચોક્કસ શબ્દ સાથે મેપ કરો.
6. **PBKDF2 કી ડેરિવેશન (Key Derivation):**
   - ૧૨ શબ્દો + પાસફ્રેઝ પર HMAC-SHA512 સાથે ૨૦૪૮ રાઉન્ડ ચલાવી ૫૧૨-બીટ માસ્ટર સીડ બને છે.

**૩. મહત્વ:**
ખાનગી કી (Private Key) યાદ રાખવા કરતાં ૧૨ અંગ્રેજી શબ્દો લખીને સાચવવા ઘણા સરળ અને સુરક્ષિત છે.''';
    }

    return r'''### 📝 Question 3: Summarize the BIP-39 Seed Phrase Generation Process.

**1. What is BIP-39?**
**BIP-39 (Bitcoin Improvement Proposal 39)** defines the industry standard for generating a human-readable mnemonic sentence (12 or 24 words) that deterministically derives a wallet's 512-bit master cryptographic seed.

**2. Step-by-Step Seed Phrase Generation Algorithm:**

• **Step 1: Cryptographic Entropy Generation (ENT)**
  - Generate cryptographically secure pseudorandom entropy between **128 to 256 bits** in multiples of 32 bits (128 bits for a 12-word phrase; 256 bits for a 24-word phrase).

• **Step 2: Checksum Calculation (CS)**
  - Hash the generated entropy using **SHA-256**:
    $$\text{Hash} = \text{SHA-256}(\text{Entropy})$$
  - Take the first $\frac{\text{ENT}}{32}$ bits of the hash as the checksum (4 bits for 128-bit entropy).

• **Step 3: Concatenation (Entropy + Checksum)**
  - Append the checksum to the end of the initial entropy:
    $$\text{Combined Data} = \text{Entropy} + \text{Checksum} = 128 + 4 = 132 \text{ bits}$$

• **Step 4: Division into 11-Bit Chunks**
  - Split the concatenated 132-bit binary string into equal **11-bit segments**:
    $$\frac{132 \text{ bits}}{11 \text{ bits/word}} = 12 \text{ segments}$$

• **Step 5: Wordlist Index Mapping**
  - Each 11-bit binary chunk represents an integer in the range $[0, 2047]$ ($2^{11} = 2048$).
  - Map each index directly to the standardized BIP-39 wordlist containing exactly 2048 unique English words.

• **Step 6: Master Seed Derivation (PBKDF2)**
  - The final mnemonic sentence is converted to a **512-bit binary master seed** using **PBKDF2** with HMAC-SHA512, an optional salt passphrase ("mnemonic" + user passphrase), and **2048 iteration rounds**.

---
**3. Summary Table:**
| Parameter | 12-Word Mnemonic | 24-Word Mnemonic |
| :--- | :--- | :--- |
| **Initial Entropy** | 128 bits | 256 bits |
| **Checksum Length** | 4 bits | 8 bits |
| **Total Bits (Entropy + CS)** | 132 bits | 264 bits |
| **Word Count** | 12 words | 24 words |
| **Output Master Seed** | 512 bits | 512 bits |''';
  }

  // Question 1: Hot Wallet vs Cold Wallet
  static String _solveWalletQuestion(String lang) {
    return r'''### 📝 Question 1: Differentiate between a Hot Wallet and a Cold Wallet.

**1. Definition:**
• **Hot Wallet:** A cryptocurrency wallet connected to the internet, facilitating quick and frequent digital asset transactions.
• **Cold Wallet:** An offline cryptocurrency storage device/medium isolated from the internet to maximize security against online threats.

**2. Detailed Comparison Table:**
| Feature | Hot Wallet (Online) | Cold Wallet (Offline) |
| :--- | :--- | :--- |
| **Internet Connectivity** | Constantly connected to the internet | Completely air-gapped / offline |
| **Security Level** | Vulnerable to malware, phishing & hacks | Maximum security; immune to online exploits |
| **Private Key Storage** | Stored on internet-enabled device/cloud | Stored in dedicated secure element chip / paper |
| **Transaction Speed** | Instant, seamless transfers | Requires manual physical device connection |
| **Setup Cost** | Free (Software apps & browser extensions) | Requires paid hardware ($60 - $200) |
| **Primary Use Case** | Daily trading, Web3 dApps & micro-payments | Long-term HODLing & large asset storage |
| **Examples** | MetaMask, Trust Wallet, Phantom, Coinbase App | Ledger Nano X, Trezor Model T, Paper Wallet |

**3. Best Practice:**
Store daily transactional funds in a hot wallet and transfer the majority of long-term assets into a cold hardware wallet.''';
  }

  // Question 2: UTXO Model with Numerical Example
  static String _solveUtxoQuestion(String lang) {
    return r'''### 📝 Question 2: Discuss the UTXO Model with a Simple Numerical Example.

**1. What is the UTXO (Unspent Transaction Output) Model?**
In Bitcoin and similar blockchains, funds are not tracked as account balances. Instead, the global state is composed of discrete chunks of unspent cryptocurrency called **UTXOs**. When spending, entire UTXOs are consumed as inputs, and new UTXOs are created as outputs.

**2. Core Rules:**
1. A UTXO is indivisible; it must be spent entirely or not at all.
2. $\sum \text{Inputs} = \sum \text{Outputs} + \text{Miner Transaction Fee}$
3. Change is returned to the sender as a newly minted change UTXO.

**3. Step-by-Step Numerical Example:**
• **Scenario:** Alice wants to send **0.5 BTC** to Bob.
• **Alice's Existing UTXO:** Alice owns 1 UTXO worth **0.8 BTC** (from a previous transaction).
• **Miner Fee:** 0.01 BTC.

**Transaction Calculation:**
• **Input:**
  - $\text{Input}_1 = 0.8\text{ BTC}$ (Alice's UTXO consumed)
• **Outputs Generated:**
  - $\text{Output}_1 = 0.5\text{ BTC}$ $\rightarrow$ Sent to Bob's Address
  - $\text{Output}_2 = 0.29\text{ BTC}$ $\rightarrow$ Change sent back to Alice's Address
• **Miner Fee:**
  $$\text{Fee} = \text{Input} - (\text{Output}_1 + \text{Output}_2) = 0.8 - (0.5 + 0.29) = 0.01\text{ BTC}$$

**4. Result:**
Alice's old 0.8 BTC UTXO is destroyed. Two new UTXOs are created: 0.5 BTC for Bob and 0.29 BTC for Alice.''';
  }

  // Question 4: Bitcoin Block Reward, Halving, and 21 Million Cap
  static String _solveHalvingQuestion(String lang) {
    return r'''### 📝 Question 4: Describe the Bitcoin Block Reward System. Explain how Halving works and why the total supply is capped at 21 Million.

**1. Bitcoin Block Reward System:**
Miners who successfully solve the Proof-of-Work puzzle and append a valid block to the blockchain receive a two-part reward:
1. **Block Subsidy (New Bitcoins):** Newly minted BTC created via the *Coinbase Transaction*.
2. **Transaction Fees:** The sum of all individual fees included by transactions in the block.

**2. How Bitcoin Halving Works:**
• The initial block subsidy in 2009 was **50 BTC** per block.
• Hardcoded in Bitcoin's protocol, the block subsidy cuts in half every **210,000 blocks** (approximately every 4 years based on a 10-minute block interval).

**Halving Timeline:**
• **2009 (Genesis):** 50 BTC / block
• **2012 (Halving 1):** 25 BTC / block
• **2016 (Halving 2):** 12.5 BTC / block
• **2020 (Halving 3):** 6.25 BTC / block
• **2024 (Halving 4):** 3.125 BTC / block
• **~2140 (Halving 32):** 0 BTC (All 21 million BTC mined; miners will earn exclusively from transaction fees).

**3. Mathematical Proof of the 21 Million Cap:**
The total supply is the sum of a finite geometric series:
$$\text{Total BTC} = 210,000 \times 50 \times \left(1 + \frac{1}{2} + \frac{1}{4} + \frac{1}{8} + \dots\right)$$
$$\text{Total BTC} = 210,000 \times 50 \times \sum_{n=0}^{32} \frac{1}{2^n} = 10,500,000 \times 2 = 20,999,999.9769 \approx 21,000,000\text{ BTC}$$

**4. Economic Rationale:**
The 21 million hard cap makes Bitcoin a disinflationary store of value (sound digital money), preventing arbitrary monetary debasement and hyperinflation.''';
  }

  // Question 5: Bitcoin Transaction Life Cycle
  static String _solveTxLifecycleQuestion(String lang) {
    return r'''### 📝 Question 5: Explain the Complete Bitcoin Transaction Life Cycle from Creation to Confirmation with Diagram.

**1. Transaction Life Cycle Stages:**

```
[1. Create & Sign] ──> [2. P2P Broadcast] ──> [3. Mempool Validation]
                                                        │
[6. 6+ Confirmations] <── [5. Block Broadcast] <── [4. PoW Mining]
```

• **Stage 1: Creation & Digital Signing**
  - Alice specifies Bob's address and amount in her wallet.
  - The wallet selects input UTXOs and creates digital signatures using Alice's private key (ECDSA/Schnorr).

• **Stage 2: Broadcast to Peer-to-Peer Network**
  - The signed transaction is propagated to neighboring Bitcoin full nodes via gossip protocol.

• **Stage 3: Mempool Validation**
  - Each receiving node validates the transaction syntax, digital signatures, and verifies that the referenced UTXOs are unspent.
  - Valid transactions enter the node's **Memory Pool (Mempool)**.

• **Stage 4: Block Assembly & Mining (Proof of Work)**
  - Miners select high-fee transactions from the Mempool to assemble a block template.
  - Miners hash the block header iteratively with different nonces until finding a hash below the network difficulty target.

• **Stage 5: Block Propagation**
  - The winning miner broadcasts the newly solved block across the network. Nodes verify all transactions and update their local ledger copies.

• **Stage 6: Confirmation Accumulation**
  - **1 Confirmation:** The block containing the transaction is added to the chain.
  - **6 Confirmations (~60 minutes):** Five subsequent blocks are mined on top, providing irreversible cryptographic finality against double-spending.''';
  }

  // Question 6: Proof of Work vs Proof of Stake
  static String _solveConsensusQuestion(String lang) {
    return r'''### 📝 Question 6: Compare Proof of Work (PoW) and Proof of Stake (PoS).

**1. Consensus Comparison Table:**
| Comparison Parameter | Proof of Work (PoW) | Proof of Stake (PoS) |
| :--- | :--- | :--- |
| **Validation Entity** | Miners | Validators |
| **Resource Used** | High-performance hardware (ASICs, GPUs) & Electricity | Staked cryptocurrency tokens |
| **Block Creation** | Solving intensive cryptographic puzzles (SHA-256) | Deterministically selected based on staked wealth |
| **Energy Consumption** | Very high (~Gigawatts) | >99.95% energy reduction (Eco-friendly) |
| **Security Against Attacks** | Must control >50% of total network hashrate | Must control >51% of total staked tokens |
| **Penalty for Malice** | Wasted electricity & capital expenditure | **Slashing:** Malicious validators lose their staked capital |
| **TPS Throughput** | ~7 TPS (Bitcoin) | 1,000+ TPS (Ethereum 2.0, Solana) |
| **Prominent Examples** | Bitcoin, Litecoin, Dogecoin, Monero | Ethereum 2.0, Cardano, Solana, Avalanche |''';
  }

  // Question 7: Forks in Blockchain (Hard vs Soft Forks)
  static String _solveForksQuestion(String lang) {
    return r'''### 📝 Question 7: Explain the Concept of Forks in Blockchain. Differentiate between Hard Forks and Soft Forks with Real-World Examples.

**1. What is a Blockchain Fork?**
A **Fork** occurs when a blockchain's consensus rules diverge, resulting in alternate chain paths or software version splits across network nodes.

**2. Hard Fork vs Soft Fork Comparison:**
| Metric | Soft Fork (Backward-Compatible) | Hard Fork (Non-Backward-Compatible) |
| :--- | :--- | :--- |
| **Compatibility** | **Backward-Compatible** with older node software | **Non-Backward-Compatible**; requires all nodes to upgrade |
| **Rule Modification** | **Tightens / Restricts** rules (Old valid blocks may become invalid, but new blocks are valid to old nodes) | **Loosens / Changes** rules (Old software rejects new blocks as invalid) |
| **Chain Splitting** | Single continuous blockchain; no new coin created | Creates **two permanent, separate chains & coins** |
| **Node Requirement** | Only a majority of miners must upgrade | 100% of nodes, miners, and exchanges must upgrade |
| **Real-World Examples** | • **SegWit (BIP-141)** on Bitcoin in 2017<br>• **BIP-66** strict DER signatures | • **Bitcoin Cash (BCH)** split from Bitcoin (2017)<br>• **Ethereum (ETH)** vs **Ethereum Classic (ETC)** (2016 DAO Fork) |''';
  }

  // =========================================================================
  // FBC UNIT 1 & OTHER SUBJECT SOLVERS
  // =========================================================================
  static String _solveFbcUnit1Question(int qNum, String lang) {
    switch (qNum) {
      case 1:
        return r'''### 📝 Question 1: What is Blockchain Technology? Explain Blockchain Architecture and DLT vs Centralized Database.

**1. Definition of Blockchain:**
A **Blockchain** is a decentralized, distributed, and immutable digital ledger that cryptographically links sequential blocks containing verified transaction data across a peer-to-peer (P2P) network.

**2. Blockchain Core Architecture:**
• **Block Header:** Previous Hash, Merkle Root, Nonce, Timestamp.
• **Block Body:** List of verified digital transactions.

**3. DLT vs Centralized Database:**
| Metric | Centralized Database (SQL) | Distributed Ledger (Blockchain) |
| :--- | :--- | :--- |
| **Authority** | Single DBA | Decentralized Consensus |
| **Immutability** | Modifiable | Immutable (Append-Only) |
| **Security** | Single Point of Failure | Cryptographic Fault Tolerant |''';
      case 2:
        return _solveWalletQuestion(lang);
      case 3:
        return _solveBip39Question(lang);
      default:
        return _solveFbcUnit2Question(qNum, lang);
    }
  }

  static String _solveAiProductQuestion(String lang) {
    return r'''### 💡 Question: Define AI Product

**1. Definition of AI Product:**
An **AI Product** is a software application, digital platform, or hardware system that integrates Artificial Intelligence algorithms (such as Machine Learning models, Deep Neural Networks, Natural Language Processing, or Computer Vision) as its core functionality to automate cognitive tasks, deliver predictive insights, and solve complex user problems dynamically.

**2. Core Characteristics:**
• **Continuous Learning & Feedback Loops:** Adapts and improves over time with user data.
• **Probabilistic Logic:** Evaluates confidence scores and probabilities rather than rigid boolean logic.
• **Data-Driven Intelligence:** Performance scales directly with the quality and volume of training data.

**3. Real-World Examples:**
• ChatGPT, GitHub Copilot, Tesla Full Self-Driving, Netflix Recommendation Engine.''';
  }

  static String _solvePeasAgentQuestion(String lang) {
    return r'''### 💡 Question: Explain Rational AI Agents and PEAS Framework

**1. Rational AI Agent:**
An autonomous entity that perceives its environment through **Sensors** and acts upon it using **Actuators** to maximize its expected performance measure.

**2. The PEAS Framework:**
• **P (Performance Measure):** Success metrics (e.g. Safety, Speed, Accuracy).
• **E (Environment):** Operational domain (e.g. Roads, Chess board, Hospital records).
• **A (Actuators):** Action mechanisms (e.g. Steering, Robotic arm, Display screen).
• **S (Sensors):** Input devices (e.g. Cameras, Sonar, Microphones, Keyboard).''';
  }

  static String _solveSmartContractQuestion(String lang) {
    return r'''### 💡 Question: What are Smart Contracts?

**1. Definition:**
A **Smart Contract** is a self-executing, decentralized digital program deployed on a blockchain that automatically executes contract terms when predefined cryptographic conditions are met.

**2. Key Characteristics:**
• **Autonomous:** Executes without intermediaries or third-party escrow.
• **Immutable:** Cannot be altered once deployed to the blockchain.
• **Deterministic:** Identical inputs yield identical results across all nodes on the EVM.''';
  }

  static String _solveMerkleQuestion(String lang) {
    return r'''### 💡 Question: Explain Merkle Tree in Blockchain

**1. Concept:**
A **Merkle Tree** (Binary Hash Tree) is a cryptographic structure where each leaf node is a transaction hash and each parent node is the hash of its concatenated children, culminating in a single **Merkle Root Hash**.

**2. Benefit:**
Enables **Simple Payment Verification (SPV)** allowing light nodes to verify transaction membership with logarithmic $O(\log N)$ proof complexity.''';
  }

  static String _solveAipdQuestion(int qNum, String lang) {
    switch (qNum) {
      case 1:
        return _solveAiProductQuestion(lang);
      case 2:
        return _solvePeasAgentQuestion(lang);
      default:
        return '''### 📝 Question $qNum: Artificial Intelligence & Product Development (AIPD)

**Core Lifecycle:**
Problem Definition -> Data Pipeline -> Model Training -> Evaluation -> Production Deployment & Drift Monitoring.''';
    }
  }

  static String _solveAipeQuestion(int qNum, String lang) {
    return '''### 📝 Question $qNum: Artificial Intelligence & Prompt Engineering (AIPE)

**Prompting Frameworks:**
• Zero-Shot Prompting: Direct instruction without examples.
• Few-Shot Prompting: 2-5 example input-output demonstration pairs.
• Chain-of-Thought (CoT): Step-by-step reasoning instructions.''';
  }

  static String _solveDbmsQuestion(int qNum, String lang) {
    return '''### 📝 Question $qNum: Database Management Systems (DBMS)

• ACID Properties: Atomicity, Consistency, Isolation, Durability.
• Relational Normalization (1NF, 2NF, 3NF, BCNF) to eliminate redundancy.''';
  }

  static String _solveCnQuestion(int qNum, String lang) {
    return '''### 📝 Question $qNum: Computer Networks (CN)

• OSI 7-Layer Model: Physical -> Data Link -> Network -> Transport -> Session -> Presentation -> Application.
• TCP vs UDP: Reliable connection-oriented vs Fast connectionless streaming.''';
  }

  static String _solveOsQuestion(int qNum, String lang) {
    return '''### 📝 Question $qNum: Operating Systems (OS)

• Process Scheduling (FCFS, Round Robin, Priority).
• Deadlock Prevention (Mutual Exclusion, Hold & Wait, No Preemption, Circular Wait).''';
  }

  static String _solveGenericQuestion(String subject, int qNum, String lang) {
    return '''### 📝 Question $qNum: $subject Assignment Solution

**1. Subject Overview:**
For **$subject**, Question $qNum addresses core theoretical foundations and analytical problem-solving required for GTU examination.

**2. Step-by-Step Solution:**
• **Primary Concept:** Core theoretical model breakdown.
• **Key Principles:** Structured implementation steps, formulas, and diagrams.
• **Exam Tips:** Focus on standard definitions and clean bullet points for full marks.''';
  }
}
