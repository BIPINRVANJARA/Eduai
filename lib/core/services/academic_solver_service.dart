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
    // Prefer explicit question prefix (e.g. "que 1", "question 2", "q3") so we don't accidentally match "3rd assignment" as question 3!
    final explicitNumMatch = RegExp(r'(?:que|question|q|prashna|પ્રશ્ન)\s*([0-9]+)', caseSensitive: false).firstMatch(lower);
    if (explicitNumMatch != null && explicitNumMatch.group(1) != null) {
      questionNumber = int.tryParse(explicitNumMatch.group(1)!) ?? 1;
    } else {
      final fallbackNumMatch = RegExp(r'\b([0-9]+)\b').firstMatch(lower);
      if (fallbackNumMatch != null && fallbackNumMatch.group(1) != null) {
        questionNumber = int.tryParse(fallbackNumMatch.group(1)!) ?? 1;
      }
    }

    final bool isUnit4 = docLower.contains('assignment 4') || docLower.contains('assignment4') || docLower.contains('unit 4') || docLower.contains('unit-4') || lower.contains('assignment 4') || lower.contains('4th assignment') || lower.contains('4 assignment');
    final bool isUnit3 = docLower.contains('assignment 3') || docLower.contains('assignment3') || docLower.contains('unit 3') || docLower.contains('unit-3') || lower.contains('assignment 3') || lower.contains('3rd assignment') || lower.contains('3 assignment');
    final bool isUnit2 = docLower.contains('assignment 2') || docLower.contains('assignment2') || docLower.contains('unit 2') || docLower.contains('unit-2') || lower.contains('assignment 2') || lower.contains('2nd assignment') || lower.contains('2 assignment');
    final bool isUnit1 = docLower.contains('assignment 1') || docLower.contains('assignment1') || docLower.contains('unit 1') || docLower.contains('unit-1') || lower.contains('assignment 1') || lower.contains('1st assignment') || lower.contains('1 assignment');
    final bool isAipd = lower.contains('aipd') || docLower.contains('aipd') || docLower.contains('product development') || docLower.contains('product design') || lower.contains('product development') || lower.contains('product design');
    final bool isAipe = lower.contains('aipe') || lower.contains('prompt') || docLower.contains('aipe') || docLower.contains('prompt');
    final bool isCdct = lower.contains('cdct') || lower.contains('cyber') || lower.contains('cloud') || lower.contains('data center') || lower.contains('virtualization') || docLower.contains('cdct') || docLower.contains('cyber') || docLower.contains('cloud');
    final bool isFbc = lower.contains('fbc') || lower.contains('blockchain') || docLower.contains('fbc') || docLower.contains('blockchain') || docLower.contains('foundation of blockchain');
    final bool isDbms = lower.contains('dbms') || docLower.contains('dbms') || docLower.contains('database');
    final bool isCn = lower.contains('cn') || docLower.contains('network');
    final bool isOs = lower.contains('os') || docLower.contains('operating system');

    if (isAipd) {
      if (isUnit2) {
        return _solveAipdUnit2Question(questionNumber, language);
      } else if (isUnit1) {
        return _solveAipdUnit1Question(questionNumber, language);
      } else {
        return _solveAipdUnit1Question(questionNumber, language);
      }
    } else if (isAipe) {
      if (isUnit2) {
        return _solveAipeUnit2Question(questionNumber, language);
      } else if (isUnit3) {
        return _solveAipeUnit3Question(questionNumber, language);
      } else if (isUnit4) {
        return _solveAipeUnit4Question(questionNumber, language);
      } else {
        return _solveAipeUnit1Question(questionNumber, language);
      }
    } else if (isCdct) {
      if (isUnit3) {
        return _solveCdctUnit3Question(questionNumber, language);
      } else if (isUnit4) {
        return _solveCdctUnit4Question(questionNumber, language);
      } else {
        return _solveCdctUnit2Question(questionNumber, language);
      }
    } else if (isFbc) {
      if (isUnit3) {
        return _solveFbcUnit3Question(questionNumber, language);
      } else if (isUnit2) {
        return _solveFbcUnit2Question(questionNumber, language);
      } else {
        return _solveFbcUnit1Question(questionNumber, language);
      }
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
  // =========================================================================
  // FBC ASSIGNMENT 1 (UNIT-1) - OFFICIAL GTU QUESTIONS (GPH HIMMATNAGAR)
  // =========================================================================
  static String _solveFbcUnit1Question(int qNum, String lang) {
    switch (qNum) {
      case 1:
        return r'''### 📝 Question 1: Differentiate between Centralized System and Decentralized System.

**1. Overview:**
• **Centralized System:** All control, computation, and data storage reside in a single central entity or master server (e.g., traditional banking databases, AWS cloud servers).
• **Decentralized System:** Control, authority, and data are distributed across multiple independent autonomous nodes with no single point of failure (e.g., Bitcoin, Ethereum).

**2. Detailed Comparison Table:**
| Parameter | Centralized System | Decentralized System (Blockchain) |
| :--- | :--- | :--- |
| **Authority** | Single central authority / administrator | Distributed consensus across all network peers |
| **Single Point of Failure** | Yes (If the central server crashes, the whole system fails) | No (Network functions seamlessly even if multiple nodes go down) |
| **Data Immutability** | Low (DB admin can edit, delete, or alter records) | High (Cryptographically sealed and immutable append-only ledger) |
| **Transparency** | Low (Internal opaque system) | Complete public or consortium auditability |
| **Throughput & Speed** | High throughput & low latency | Lower throughput due to network consensus validation |
| **Trust Model** | Trust placed in a single third-party entity | Trustless (Cryptographic proofs and consensus protocols) |
| **Examples** | Oracle DB, Visa payment servers, Client-Server apps | Bitcoin, Ethereum, Hyperledger Fabric |''';

      case 2:
        return r'''### 📝 Question 2: Explain Cryptographic Hash Function with its Properties.

**1. Definition:**
A **Cryptographic Hash Function** is a mathematical algorithm that takes an arbitrary-sized block of data as input and produces a fixed-size bit string (hash value or message digest) deterministically. In blockchain, **SHA-256** (Secure Hash Algorithm 256-bit) is the most widely adopted standard.

**2. Core Cryptographic Properties:**
1. **Deterministic:** The same input data will always produce the exact same hexadecimal output hash.
2. **Fixed Output Length:** Regardless of input size (1 character or 10 GB), SHA-256 always outputs exactly 256 bits (64 hex characters).
3. **Pre-image Resistance (One-Way):** Given a hash $H$, it is computationally infeasible to determine the original input $M$ such that $\text{Hash}(M) = H$.
4. **Second Pre-image Resistance (Weak Collision Resistance):** Given an input $M_1$, it is computationally infeasible to find another input $M_2 \neq M_1$ such that $\text{Hash}(M_1) = \text{Hash}(M_2)$.
5. **Collision Resistance (Strong Collision Resistance):** It is infeasible to find any two different inputs $M_1$ and $M_2$ that produce the same hash $\text{Hash}(M_1) = \text{Hash}(M_2)$.
6. **Avalanche Effect:** Even a microscopic 1-bit change in the input produces a drastically different and uncorrelated hash output.
7. **High Computational Efficiency:** Computing the hash of any input data is fast and lightweight.

**3. Blockchain Application:**
Used for block header linking (Previous Hash), Merkle tree verification, and Bitcoin Proof-of-Work difficulty target mining.''';

      case 3:
        return r'''### 📝 Question 3: Summarize CAP Theorem.

**1. What is CAP Theorem (Brewer's Theorem)?**
The **CAP Theorem** states that any distributed data store can simultaneously provide at most **two out of three** guarantees:

```
                  Consistency (C)
                       / \
                      /   \
                     /  *  \
                    /       \
     Availability (A) ────── Partition Tolerance (P)
```

**2. The Three Dimensions:**
• **C - Consistency:** Every read receives the most recent write or an error. All nodes see identical data simultaneously.
• **A - Availability:** Every non-failing node returns a non-error response for every request, without guarantee that it contains the latest write.
• **P - Partition Tolerance:** The system continues to operate despite an arbitrary number of messages being dropped or delayed by network network splits.

**3. Blockchain Context (AP vs CP):**
In distributed peer-to-peer networks across the globe, **Partition Tolerance (P)** is unavoidable. Thus, distributed ledgers must choose between **CP** and **AP**:
• **Bitcoin / Ethereum (AP with Eventual Consistency):** Prioritize Availability and Partition Tolerance. Temporary forks are permitted, resolving to strong consistency via Nakamoto longest-chain consensus.
• **Traditional Enterprise DBMS (CA):** Works in centralized single-datacenter environments without network partitions.''';

      case 4:
        return r'''### 📝 Question 4: Explain Merkle Tree, Merkle Root and Efficient Data Verification.

**1. What is a Merkle Tree?**
A **Merkle Tree** (Binary Hash Tree) is a hierarchical cryptographic tree structure where bottom leaf nodes contain cryptographic hashes of individual transactions, and each non-leaf parent node contains the hash of its concatenated child nodes.

```
                  [ Merkle Root: H_ABCD ]
                        /         \
                 [ H_AB ]         [ H_CD ]
                  /    \           /    \
              [ H_A ] [ H_B ]   [ H_C ] [ H_D ]
                 |       |         |       |
               Tx_A    Tx_B      Tx_C    Tx_D
```

**2. Merkle Root:**
The single root hash at the top of the tree, stored inside the block header. It represents a compact cryptographic fingerprint of all transactions within that block.

**3. Efficient Data Verification (SPV Proofs):**
• Allows Light Nodes (Simple Payment Verification) to verify whether a transaction is included in a block without downloading the entire blockchain.
• Verification complexity is logarithmic **$O(\log_2 N)$** instead of linear $O(N)$. For a block with 4,096 transactions, only 12 hashes (Merkle audit path) are needed for cryptographic proof!''';

      case 5:
        return r'''### 📝 Question 5: Compare Distributed Ledger Technology (DLT) and Traditional Database.

**1. Architectural Comparison Table:**
| Feature | Traditional Database (RDBMS) | Distributed Ledger Technology (DLT) |
| :--- | :--- | :--- |
| **Architecture** | Centralized client-server or master-slave | Distributed Peer-to-Peer (P2P) network |
| **Control Authority** | Managed by a Central DBA (Database Administrator) | No single authority; governed by consensus protocol |
| **CRUD Operations** | Full CRUD (Create, Read, Update, Delete) | Append-Only (Create, Read); Updates/Deletes forbidden |
| **Immutability** | Low; admin can overwrite historical rows | Cryptographically sealed; historic tampering is detected |
| **Trust Factor** | Centralized trust in institutional owner | Trustless; verified by cryptographic proofs |
| **Performance** | Millions of queries/second; ultra-low latency | Lower TPS (Transactions Per Second) due to consensus |
| **Fault Tolerance** | Single point of failure; relies on backups | Byzantine Fault Tolerant; runs even with compromised nodes |
| **Prominent Examples** | MySQL, PostgreSQL, Oracle, MongoDB | Hyperledger Fabric, Corda, Ethereum, Bitcoin |''';

      case 6:
        return r'''### 📝 Question 6: Describe Byzantine Generals Problem.

**1. The Problem Scenario:**
• A group of Byzantine generals surround an enemy city with their army divisions.
• They must agree on a common battle plan: **Attack** or **Retreat**.
• If all generals attack simultaneously, they win. If they attack uncoordinated, they suffer catastrophic defeat.
• The generals can communicate only through messengers.
• **The Challenge:** Some generals and messengers may be **traitors** sending conflicting or misleading orders to sabotage the mission.

**2. Mathematical Proof:**
In classical distributed systems, consensus cannot be reached if more than one-third of the participants are malicious:
$$\text{Faulty Nodes } m < \frac{N}{3} \implies N \ge 3m + 1$$

**3. Blockchain Resolution:**
Satoshi Nakamoto solved this challenge in 2008 through **Proof of Work (PoW) consensus**:
Miners must spend computational energy (hash power) to solve mathematical puzzles. Tampering with messages requires controlling >50% of the entire global computational hash power, making betrayal economically disastrous.''';

      case 7:
        return r'''### 📝 Question 7: Explain Consensus Algorithm.

**1. Definition:**
A **Consensus Algorithm** is a distributed protocol that enables independent, untrusted nodes across a peer-to-peer blockchain network to reach unified agreement on the current state of the shared digital ledger.

**2. Key Objectives of Consensus:**
1. **Agreement:** All honest nodes agree on the same sequence of transactions.
2. **Validity:** Proposed transactions adhere to protocol validation rules.
3. **Integrity:** No transaction can be spent twice (prevents double-spending).
4. **Fault Tolerance:** System operates normally despite node crashes or malicious actors.

**3. Major Consensus Types:**
• **Proof of Work (PoW):** Nodes (miners) compete to solve hard cryptographic hash puzzles (e.g., Bitcoin). Highly secure, high energy consumption.
• **Proof of Stake (PoS):** Validators stake economic tokens to be selected to propose blocks (e.g., Ethereum 2.0). 99.95% energy reduction.
• **Practical Byzantine Fault Tolerance (PBFT):** Multi-round voting system used in permissioned enterprise blockchains (e.g., Hyperledger Fabric).''';

      case 8:
        return r'''### 📝 Question 8: Discuss Anatomy of the Block with Diagram.

**1. Structural Overview:**
A blockchain block is divided into two primary sections: the **Block Header** (metadata) and the **Block Body** (transaction data).

```
┌──────────────────────────────────────────────────────────┐
│                      BLOCK HEADER                        │
├──────────────────────────────┬───────────────────────────┤
│ Block Version (4 bytes)      │ Nonce (4 bytes)           │
│ Previous Block Hash (32 B)   │ Difficulty Target (4 B)   │
│ Merkle Root Hash (32 bytes)  │ Timestamp (4 bytes)       │
└──────────────────────────────┴───────────────────────────┘
┌──────────────────────────────────────────────────────────┐
│                      BLOCK BODY                          │
├──────────────────────────────────────────────────────────┤
│ Transaction Counter (e.g., 2,450 transactions)           │
│ • Coinbase Transaction (Miner block reward + fees)       │
│ • Transaction 1 [TxID, Inputs, Outputs, Signature]       │
│ • Transaction 2 [TxID, Inputs, Outputs, Signature]       │
│ • ...                                                    │
│ • Transaction N                                          │
└──────────────────────────────────────────────────────────┘
```

**2. Component Explanations:**
1. **Previous Block Hash:** 256-bit hash of the predecessor block, creating the tamper-evident chain link.
2. **Merkle Root Hash:** 256-bit summary hash representing all transactions in the block.
3. **Timestamp:** Epoch time when the block was assembled.
4. **Difficulty Target & Nonce:** The 32-bit arbitrary counter incremented during Proof-of-Work mining until the header hash meets difficulty requirements.''';

      case 9:
        return r'''### 📝 Question 9: Outline Three Differences Between Client-Server and Peer-to-Peer Network Topologies.

**1. Core Differences:**
| Feature | Client-Server Architecture | Peer-to-Peer (P2P) Architecture |
| :--- | :--- | :--- |
| **Node Roles & Hierarchy** | Strict master-slave hierarchy. Dedicated central servers serve passive client devices. | Equal hierarchy. Every node acts as both a client (consumer) and a server (supplier). |
| **Failure Vulnerability** | High vulnerability. If the central server fails or gets attacked, all service halts. | Robust resilience. Network continues seamlessly even if several peer nodes go offline. |
| **Scalability & Bottlenecks** | Bottlenecks arise as client requests overwhelm the central server bandwidth. | Bandwidth and storage scale organically as new peers join the network. |

**2. Real-World Applications:**
• **Client-Server:** Web browsing (HTTP/HTTPS), email servers (SMTP), centralized databases.
• **Peer-to-Peer:** Bitcoin network, BitTorrent file sharing, Ethereum devp2p.''';

      case 10:
        return r'''### 📝 Question 10: Illustrate the Signing and Verification Steps in a Digital Signature Pipeline.

**1. Concept:**
Digital signatures use asymmetric cryptography (Public/Private key pairs) to provide **Authentication**, **Non-repudiation**, and **Data Integrity** for blockchain transactions.

```
1. SENDER SIGNING PIPELINE (Private Key):
   Transaction Data ──> [SHA-256 Hash] ──> Digest ──> [Encrypt with Private Key] ──> Digital Signature

2. RECEIVER VERIFICATION PIPELINE (Public Key):
   Transaction Data ──> [SHA-256 Hash] ──> Digest A
   Digital Signature ──> [Decrypt with Public Key] ──> Digest B
   Check: If Digest A == Digest B ──> VALID TRANSACTION ✅
```

**2. Step-by-Step Mechanism:**
• **Step 1 (Hashing):** Sender computes cryptographic hash $H = \text{SHA-256}(M)$ of the transaction message.
• **Step 2 (Signing):** Sender encrypts the digest $H$ using their secret **Private Key** (ECDSA/secp256k1) to produce the **Digital Signature**.
• **Step 3 (Broadcast):** Message $M$, Digital Signature, and Sender's **Public Key** are broadcast to the network.
• **Step 4 (Verification):** Any node hashes the message and decrypts the signature using the Public Key. If both digests match, the signature is mathematically authentic.''';

      default:
        return _solveGenericQuestion('Fundamentals of Blockchain (FBC) - Assignment 1 (Unit-1)', qNum, lang);
    }
  }

  // =========================================================================
  // FBC ASSIGNMENT 3 (UNIT-3) - OFFICIAL GTU QUESTIONS (GPH HIMMATNAGAR)
  // =========================================================================
  static String _solveFbcUnit3Question(int qNum, String lang) {
    switch (qNum) {
      case 1:
        return r'''### 📝 Question 1: Explain the Ethereum Virtual Machine (EVM) and the Concept of Gas Fees.

**1. Ethereum Virtual Machine (EVM):**
• The **EVM** is the runtime environment for executing smart contracts on the Ethereum blockchain.
• It operates as a globally distributed, decentralized state machine where thousands of nodes independently execute identical bytecode, ensuring deterministic results.
• EVM is **Turing-complete**, meaning it can perform any computation given sufficient gas resources.

**2. The Concept of Gas Fees:**
• **Gas** is the fundamental unit measuring the computational effort required to execute specific operations or transactions on the EVM.
• **Purpose:**
  1. Prevents infinite loops and Denial-of-Service (DoS) attacks (Halting Problem).
  2. Compensates network validators for hardware compute and storage costs.

**3. Gas Formula (EIP-1559 Standard):**
$$\text{Total Transaction Fee} = \text{Gas Units Used} \times (\text{Base Fee} + \text{Priority Fee / Tip})$$
• **Base Fee:** Mandatory burn fee determined by network block congestion.
• **Priority Fee (Tip):** Optional incentive given directly to validators for faster inclusion.
• **Gas Limit:** Maximum gas units the sender is willing to consume for the transaction (minimum 21,000 for standard ETH transfer).''';

      case 2:
        return r'''### 📝 Question 2: Differentiate between Ether (ETH) and ERC-20 Tokens.

**1. Detailed Comparison Table:**
| Feature | Ether (ETH) | ERC-20 Tokens |
| :--- | :--- | :--- |
| **Nature** | Native cryptocurrency of the Ethereum blockchain | Fungible token standard created via smart contracts |
| **Layer Level** | Base protocol layer (Layer 1) | Application layer running on top of the EVM |
| **Smart Contract** | Native coin; no contract needed to exist | Implements standard smart contract interface |
| **Transaction Fees** | Required to pay Gas fees for all operations | Cannot directly pay network Gas fees (must use ETH) |
| **Storage Mechanism** | Tracked directly at account balance state | Tracked inside `mapping(address => uint256)` in the token contract |
| **Standard Functions** | Built-in EVM opcode balance transfers | Implements `transfer()`, `approve()`, `transferFrom()`, `balanceOf()` |
| **Prominent Examples** | ETH | USDT (Tether), UNI (Uniswap), LINK (Chainlink), SHIB |''';

      case 3:
        return r'''### 📝 Question 3: Discuss Variables, Functions, and Mappings with Suitable Solidity Code Examples.

**1. Core Components in Solidity:**
• **Variables:** State variables (stored permanently on blockchain storage), Local variables (temporary in memory/stack).
• **Functions:** Executable units of code with visibility (`public`, `private`, `internal`, `external`) and state mutability (`view`, `pure`, `payable`).
• **Mappings:** Hash-table key-value store defined as `mapping(KeyType => ValueType)`.

**2. Comprehensive Solidity Code Example:**
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StudentRegistry {
    // 1. STATE VARIABLES
    address public owner;
    uint256 public totalStudents;

    // 2. MAPPINGS (Roll Number => Student Marks)
    mapping(uint256 => uint256) public studentMarks;
    mapping(address => bool) public isRegistered;

    constructor() {
        owner = msg.sender;
    }

    // 3. FUNCTIONS
    // Write function to assign marks
    function setMarks(uint256 _rollNo, uint256 _marks) public {
        require(msg.sender == owner, "Only owner can set marks");
        studentMarks[_rollNo] = _marks;
        totalStudents++;
    }

    // Read function (view modifier - costs 0 gas when called externally)
    function getMarks(uint256 _rollNo) public view returns (uint256) {
        return studentMarks[_rollNo];
    }
}
```''';

      case 4:
        return r'''### 📝 Question 4: Write and Explain a Simple “Hello World” Smart Contract Using Solidity.

**1. Solidity Smart Contract Code:**
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HelloWorld {
    // State variable stored on blockchain storage
    string private message;

    // Constructor runs once during contract deployment
    constructor() {
        message = "Hello, World!";
    }

    // Function to read the message (View function: 0 gas for read)
    function getMessage() public view returns (string memory) {
        return message;
    }

    // Function to update the message (State change: consumes gas)
    function setMessage(string memory _newMessage) public {
        message = _newMessage;
    }
}
```

**2. Code Explanation:**
1. `SPDX-License-Identifier`: Specifies machine-readable open-source licensing (MIT).
2. `pragma solidity ^0.8.20;`: Compiler directive ensuring compatibility with version 0.8.20 and above.
3. `contract HelloWorld`: Declares contract container equivalent to a class in Java/C++.
4. `string private message`: State variable persisted permanently in the contract's Ethereum storage.
5. `getMessage()`: Marked as `view` because it reads contract storage without altering blockchain state.''';

      case 5:
        return r'''### 📝 Question 5: Write the Steps of Compiling and Deploying a Solidity Smart Contract Using Remix IDE on an Ethereum Testnet.

**1. Prerequisites:**
• Web Browser opening Remix IDE (`https://remix.ethereum.org`).
• MetaMask browser wallet installed and switched to a testnet (e.g., Sepolia or Holesky) with free testnet ETH.

**2. Step-by-Step Workflow:**
• **Step 1: Create File:**
  - In Remix File Explorer, create a new file named `HelloWorld.sol` inside the `contracts/` directory and paste your Solidity code.
• **Step 2: Compile Contract:**
  - Click the **Solidity Compiler** tab on the left sidebar.
  - Select compiler version matching pragma (e.g., `0.8.20`).
  - Click **Compile HelloWorld.sol** (or press `Ctrl + S`). Ensure green checkmark appears.
• **Step 3: Connect Environment:**
  - Navigate to the **Deploy & Run Transactions** tab.
  - In the **Environment** dropdown, change from "Remix VM" to **"Injected Provider - MetaMask"**.
  - Approve the MetaMask connection popup. Your testnet account address and balance will display.
• **Step 4: Deploy Contract:**
  - Select your compiled contract (`HelloWorld`) from the Contract dropdown.
  - Click the orange **Deploy** button.
  - Confirm the gas fee in the MetaMask popup notification.
• **Step 5: Interact with Deployed Contract:**
  - Once mined, the deployed contract appears under **Deployed Contracts** at the bottom left.
  - Test functions: Click `getMessage` (blue button) to read output, and `setMessage` (orange button) to write.''';

      case 6:
        return r'''### 📝 Question 6: Give the Introduction of MetaMask.

**1. What is MetaMask?**
• **MetaMask** is a leading non-custodial cryptocurrency software wallet and browser extension (Chrome, Brave, Firefox) used to interact with the Ethereum blockchain and EVM-compatible networks (Polygon, Arbitrum, BSC).
• Founded in 2016 by ConsenSys, it acts as a bridge between standard web browsers and decentralized Web3 applications (dApps).

**2. Key Features:**
1. **Key Management & Security:** Users hold their own private keys and 12-word Secret Recovery Phrase (BIP-39). MetaMask never stores user passwords or private keys on centralized servers.
2. **dApp Web3 Injection:** Injects the `window.ethereum` JavaScript provider object into web pages, allowing instant login and transaction signing.
3. **Multi-Network Compatibility:** Seamlessly toggles between Ethereum Mainnet, Layer-2 rollups (Arbitrum, Optimism), and developer testnets (Sepolia).
4. **Token & Asset Management:** Supports storing, tracking, and sending ETH, ERC-20 fungible tokens, and ERC-721/1155 NFTs.''';

      default:
        return _solveGenericQuestion('Fundamentals of Blockchain (FBC) - Assignment 3 (Unit-3)', qNum, lang);
    }
  }

  // =========================================================================
  // AIPD ASSIGNMENT 1 (UNIT-1) - OFFICIAL GTU QUESTIONS (GPH HIMMATNAGAR)
  // =========================================================================
  static String _solveAipdUnit1Question(int qNum, String lang) {
    switch (qNum) {
      case 1:
        return _solveAiProductQuestion(lang);

      case 2:
        return r'''### 📝 Question 2: Briefly Differentiate between an AI Tool and an AI Product, Providing One Real-World Example of Each.

**1. Comparison Overview:**
| Dimension | AI Tool | AI Product |
| :--- | :--- | :--- |
| **Definition** | A specialized utility, model, or algorithm designed to perform a single isolated AI task. | A complete end-to-end software application that embeds AI to solve a comprehensive user workflow. |
| **Scope** | Narrow and technical; usually accessed via API or code library. | Holistic; includes UI, UX, database, business logic, and support. |
| **User Experience** | Requires developer integration or manual input/output handling. | Intuitive interface tailored for consumer or enterprise end-users. |
| **Autonomous Workflow** | Does not manage user state, history, or business lifecycle. | Manages user history, personalized feedback loops, and workflows. |

**2. Real-World Examples:**
• **AI Tool Example:** **OpenAI Whisper API** (An isolated model API that accepts audio and outputs raw transcribed text).
• **AI Product Example:** **Otter.ai / Zoom AI Companion** (A full product that joins meetings, records video, transcribes dialogue, generates action items, emails summaries, and integrates with CRM).''';

      case 3:
        return r'''### 📝 Question 3: Explain Components of an AI System with Example.

**1. Core Architectural Components:**
```
[1. Data Ingestion] ──> [2. AI Model Engine] ──> [3. Application Logic] ──> [4. User Interface]
         ▲                                                                            │
         └─────────────────── [5. Feedback & Telemetry Loop] <────────────────────────┘
```

1. **Data Ingestion & Preprocessing Pipeline:** Collects raw data (sensor inputs, user queries, images), cleans, normalizes, and converts it into numerical vector embeddings.
2. **AI Model Engine (Inference Core):** The trained machine learning or deep learning algorithm (e.g., Transformer, CNN, Random Forest) that generates predictions or content.
3. **Application & Business Logic Layer:** Validates predictions, enforces safety guardrails, queries relational databases, and applies business rules.
4. **User Interface / Interaction Layer (UI/UX):** Web or mobile frontend presenting outputs via chat, charts, or automated triggers.
5. **Feedback & Telemetry Loop:** Logs user interactions, corrections, and satisfaction metrics to monitor model drift and retrain models.

**2. Real-World Example (Ride-Hailing App - Uber):**
• *Data Pipeline:* GPS locations, historical traffic, and weather.
• *AI Model:* Dynamic price prediction & route estimation algorithms.
• *Business Logic:* Matching nearest driver; applying surge caps.
• *UI/UX:* Map display showing ETA and upfront pricing to the passenger.''';

      case 4:
        return r'''### 📝 Question 4: Give Overview of Generative AI.

**1. What is Generative AI?**
**Generative AI (GenAI)** refers to a class of artificial intelligence models that can generate brand-new, realistic synthetic content—including text, images, computer code, audio, and synthetic video—by learning underlying statistical patterns from massive training datasets.

**2. Generative AI vs Traditional AI:**
• **Traditional / Analytical AI:** Analyzes data to categorize, predict, or classify (e.g., Spam classifier: "Is this email spam or not?").
• **Generative AI:** Synthesizes new artifacts (e.g., "Draft a professional marketing email for our new product launch.").

**3. Foundation Architectures:**
1. **Transformers:** Foundation of Large Language Models (GPT-4, Claude, Gemini, LLaMA) using self-attention mechanisms.
2. **Diffusion Models:** Foundation of image/video synthesis (Midjourney, Stable Diffusion, Sora).
3. **Variational Autoencoders (VAEs) & GANs:** Used for speech synthesis and generative design.''';

      case 5:
        return r'''### 📝 Question 5: Explain Working of Large Language Models (LLMs) with Its Applications, Advantages, and Limitations.

**1. How LLMs Work:**
• **Architecture:** Built upon the **Transformer** architecture leveraging Multi-Head Self-Attention mechanisms.
• **Core Mechanism (Next-Token Prediction):** LLMs tokenize input text into subwords and calculate the conditional probability distribution for the most likely subsequent token:
$$P(w_t \mid w_1, w_2, \dots, w_{t-1})$$
• **Training Pipeline:**
  1. *Self-Supervised Pretraining:* Trained on trillions of web tokens to learn grammar, facts, and reasoning.
  2. *Supervised Fine-Tuning (SFT):* Tuned on instruction-following datasets.
  3. *RLHF (Reinforcement Learning from Human Feedback):* Aligned with human preferences for safety and helpfulness.

**2. Applications:** Code generation, multilingual translation, automated customer support, document summarization, legal analysis.

**3. Advantages:** Rapid context processing, zero-shot task versatility, natural language interface.

**4. Limitations:** Hallucinations (generating plausible yet incorrect facts), high computational costs, static knowledge cutoff dates, security risks (prompt injections).''';

      case 6:
        return r'''### 📝 Question 6: Explain Types of AI Models: Text, Image, Speech, Embeddings.

**1. The Four Major AI Model Modalities:**
1. **Text Models (Large Language Models):**
   - *Function:* Ingest and generate natural language and code.
   - *Architectures:* Transformers (Decoder-only like GPT-4, LLaMA).
   - *Use Cases:* Chatbots, essay drafting, summarization, logical reasoning.
2. **Image Models (Computer Vision & Generation):**
   - *Function:* Image recognition, object detection, segmentation, and synthetic image synthesis.
   - *Architectures:* Convolutional Neural Networks (CNNs), Vision Transformers (ViT), Diffusion Models.
   - *Use Cases:* Autonomous vehicles, medical radiography diagnosis, Midjourney.
3. **Speech / Audio Models:**
   - *Function:* Speech-to-Text (ASR) and Text-to-Speech (TTS).
   - *Architectures:* Whisper, Conformer, Tacotron, WaveNet.
   - *Use Cases:* Voice assistants (Siri, Alexa), real-time call center transcribers.
4. **Embedding Models:**
   - *Function:* Transform unstructured text, images, or audio into dense numerical vectors capturing semantic meaning in high-dimensional vector space.
   - *Use Cases:* Vector similarity search, Semantic RAG search, recommendation engines.''';

      case 7:
        return r'''### 📝 Question 7: Differentiate between Generative AI vs Analytical AI with Example.

**1. Detailed Comparison Table:**
| Feature | Analytical (Discriminative) AI | Generative AI |
| :--- | :--- | :--- |
| **Objective** | Analyzes existing data to predict, categorize, or classify | Creates brand-new synthetic data, text, or media |
| **Mathematical Goal** | Estimates conditional probability $P(Y \mid X)$ | Estimates joint probability $P(X, Y)$ or data distribution $P(X)$ |
| **Output Type** | Discrete labels, probabilities, or numerical values | Complex human-like content (essays, images, audio, code) |
| **Creativity** | Zero creativity; deterministic classification | High generative creativity and synthesis capabilities |
| **Model Architectures** | SVM, Random Forest, Logistic Regression, ResNet | Transformers, Diffusion Models, GANs, VAEs |

**2. Real-World Examples:**
• **Analytical AI:** Fraud Detection System (Flags a bank transaction as: `98% Fraud Probability`).
• **Generative AI:** AI Copywriter (Generates 5 personalized promotional emails tailored to the customer's spending history).''';

      case 8:
        return r'''### 📝 Question 8: How to Select AI Model for Product Use.

**1. Systematic Model Selection Framework:**
When choosing an AI model for production systems, evaluate across 5 essential dimensions:

1. **Performance & Accuracy Requirements:**
   - Evaluate benchmark metrics (MMLU, BLEU, F1-Score, human evaluation).
   - Determine if the use case tolerates probabilistic errors (creative writing) or requires 100% deterministic accuracy (medical/financial).
2. **Latency & Throughput Constraints:**
   - Real-time conversational apps require <500ms First Token Latency (TTFT). Choose smaller distilled models (e.g., LLaMA-8B) over massive models.
3. **Inference & Operational Cost:**
   - Calculate cost per 1M tokens or GPU cloud hosting expenses to maintain a viable business model.
4. **Data Privacy & Compliance:**
   - Regulated healthcare (HIPAA) or banking domains may require self-hosted open-weight models rather than public third-party APIs.
5. **Customizability & Adaptability:**
   - Does the model support RAG (Retrieval-Augmented Generation) or efficient parameter fine-tuning (LoRA/QLoRA)?''';

      case 9:
        return r'''### 📝 Question 9: Give Overview of Multi-Agent AI with Applications.

**1. What is Multi-Agent AI?**
A **Multi-Agent System (MAS)** consists of multiple autonomous AI agents that collaborate, negotiate, and execute specialized roles to accomplish complex, multi-step goals that exceed the capacity of any single monolithic model.

```
                  [ Orchestrator / Planner Agent ]
                     /           |           \
           [ Research Agent ] [ Coder Agent ] [ Tester Agent ]
```

**2. Core Characteristics:**
• **Specialized Personas:** Each agent possesses dedicated system instructions, memory, and specialized tools (web search, code execution, SQL query).
• **Autonomous Delegation:** Agents break down monolithic objectives into manageable subtasks.
• **Iterative Peer Review:** Agents review, critique, and debug each other's outputs before final delivery.

**3. Applications:**
1. *Software Engineering:* Automated development pipelines where Planner, Developer, and QA agents build apps autonomously (e.g., AutoGen, CrewAI).
2. *Financial Market Analysis:* Separate agents tracking news sentiment, technical charts, and macroeconomic data to produce unified investment reports.''';

      case 10:
        return r'''### 📝 Question 10: Explain Human-in-the-Loop (HITL) Systems.

**1. What is Human-in-the-Loop (HITL)?**
A **Human-in-the-Loop** system is an AI workflow design where human judgment actively intervenes in the training, validation, operation, or decision-making cycle of an automated AI system.

**2. Key Roles of HITL:**
1. **Active Data Labeling & Curation:** Humans annotate complex, ambiguous edge cases that automated algorithms fail to interpret.
2. **Confidence-Based Fallback:** If the AI model's confidence score drops below a safety threshold (e.g., <85%), the decision is seamlessly routed to a human specialist.
3. **Safety & Ethical Oversight:** In high-stakes environments (medical diagnostics, judicial sentencing, loan approvals), the AI provides recommendations while the final approval rests with a human expert.
4. **Model Reinforcement (RLHF):** Humans rank model outputs to guide AI behavior towards safety and compliance.

**3. Benefits:** Drastically mitigates hallucination risk, ensures regulatory accountability, and guarantees ethical compliance.''';

      case 11:
        return r'''### 📝 Question 11: Explain Basic AI System Architecture with Conceptual Diagram.

**1. Conceptual AI System Architecture:**
```
┌──────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                     │
│   Web / Mobile UI • Voice Assistants • Chat Interfaces   │
└────────────────────────────┬─────────────────────────────┘
                             │ (API Requests / REST / WebSocket)
┌────────────────────────────▼─────────────────────────────┐
│                 APPLICATION & ORCHESTRATION              │
│   • Request Validator       • Prompt Orchestrator / LangChain
│   • Safety Guardrails       • Session & Context Memory    │
└────────────────────────────┬─────────────────────────────┘
                             │
       ┌─────────────────────┴─────────────────────┐
       ▼                                           ▼
┌──────────────────────────────┐ ┌─────────────────────────┐
│     RAG RETRIEVAL ENGINE     │ │     AI MODEL INFERENCE  │
│ • Vector DB (Embeddings)     │ │ • Foundation LLMs       │
│ • Full-Text Knowledge Base   │ │ • Fine-Tuned Domain Mod │
└──────────────────────────────┘ └─────────────────────────┘
                               │
┌──────────────────────────────▼───────────────────────────┐
│                DATA & TELEMETRY INFRASTRUCTURE           │
│   PostgreSQL • Storage Buckets • Analytics & Drift Logs  │
└──────────────────────────────────────────────────────────┘
```

**2. Layer Breakdown:**
1. **Presentation Layer:** User touchpoints capturing input prompts and displaying responses.
2. **Application & Orchestration Layer:** Handles auth, sanitizes input, manages conversation history, and routes to appropriate services.
3. **RAG & Inference Layer:** Pairs live enterprise context from vector search with deep intelligence from generative foundation models.
4. **Data & Telemetry Layer:** Persists structured records and tracks model accuracy over time.''';

      default:
        return _solveGenericQuestion('Artificial Intelligence & Product Development (AIPD) - Assignment 1 (Unit-1)', qNum, lang);
    }
  }

  // =========================================================================
  // AIPD ASSIGNMENT 2 (UNIT-2) - OFFICIAL GTU QUESTIONS (GPH HIMMATNAGAR)
  // =========================================================================
  static String _solveAipdUnit2Question(int qNum, String lang) {
    switch (qNum) {
      case 1:
        return r'''### 📝 Question 1: Define Design Thinking. List and Explain Its Five Stages in Sequential Order.

**1. Definition of Design Thinking:**
**Design Thinking** is a human-centered, iterative problem-solving methodology that seeks to understand user needs, challenge assumptions, redefine problems, and create innovative solutions through prototyping and testing.

**2. Five Stages in Sequential Order (Stanford d.school Framework):**
```
[1. Empathize] ──> [2. Define] ──> [3. Ideate] ──> [4. Prototype] ──> [5. Test]
       ▲                                                                 │
       └──────────────────────── Iterative Loop ────────────────────────┘
```

1. **Stage 1: Empathize (Understand User Needs):**
   - Conduct interviews, observations, and immersive research to understand users' emotions, pain points, and motivations without bias.
2. **Stage 2: Define (State the Core Problem):**
   - Synthesize research findings into a clear, human-centered **Problem Statement** (e.g., using Point of View / POV frameworks).
3. **Stage 3: Ideate (Brainstorm Creative Solutions):**
   - Generate a broad range of creative ideas using techniques like Brainstorming, Mind Mapping, and Worst Possible Idea.
4. **Stage 4: Prototype (Build Experimental Models):**
   - Create quick, inexpensive, low-fidelity versions of solutions (paper wireframes, click-through mockups) to investigate idea feasibility.
5. **Stage 5: Test (Rigorous Validation):**
   - Put prototypes in front of real users to collect direct feedback, uncover flaws, and refine earlier stages iteratively.''';

      case 2:
        return r'''### 📝 Question 2: What is an Empathy Map? Briefly Explain Its Four Primary Quadrants.

**1. What is an Empathy Map?**
An **Empathy Map** is a collaborative visual tool used by product designers and AI developers to synthesize user research, gain deep insights into user mindset, and establish emotional alignment with end-users.

**2. The Four Primary Quadrants:**
```
┌──────────────────────────────┬──────────────────────────────┐
│            SAYS              │            THINKS            │
│ What the user states aloud   │ What occupies user's mind    │
│ during user interviews.      │ but they may not say aloud.  │
├──────────────────────────────┼──────────────────────────────┤
│            DOES              │            FEELS             │
│ Observable physical actions, │ Emotional states, anxieties, │
│ behaviors, and habits.       │ hopes, and frustrations.     │
└──────────────────────────────┴──────────────────────────────┘
```

• **Says:** Contains direct, verbatim quotes spoken by the user during interviews (e.g., *"I spend too much time copying data into spreadsheets"*).
• **Thinks:** Captures the user's internal thoughts, beliefs, and unspoken aspirations (e.g., *"Will AI replace my job if I automate this?"*).
• **Does:** Documents concrete behavioral patterns and workarounds the user takes to accomplish goals (e.g., *Refreshes page repeatedly; writes passwords on sticky notes*).
• **Feels:** Maps emotional states—such as anxiety, confusion, delight, or impatience (e.g., *Overwhelmed by complex college software portals*).''';

      case 3:
        return r'''### 📝 Question 3: Explain Steps to Create Empathy Map with Its Applications.

**1. Steps to Create an Empathy Map:**
1. **Step 1: Define Scope and Target Persona:** Establish who you are mapping (e.g., college student, faculty) and the specific problem context.
2. **Step 2: Gather User Research:** Conduct qualitative interviews, contextual observations, and user surveys to gather real primary data.
3. **Step 3: Prepare the Canvas:** Draw the 4 quadrants (Says, Thinks, Does, Feels) alongside Pain & Gain sections.
4. **Step 4: Brainstorm & Populate Individually:** Team members write individual observations on sticky notes and place them into quadrants.
5. **Step 5: Cluster and Synthesize Themes:** Group related sticky notes to identify unexpected contradictions (e.g., user *says* one thing but *does* another).

**2. Applications in AI Product Design:**
• Uncovering hidden user pain points to guide AI model feature prioritization.
• Designing empathetic conversational AI bots that align with user emotional states.
• Aligning multidisciplinary teams (engineers, designers, product managers) around genuine user needs.''';

      case 4:
        return r'''### 📝 Question 4: Explain Key Elements That Make a Good User Persona.

**1. What is a User Persona?**
A **User Persona** is a semi-fictional archetype representing a key user segment based on empirical qualitative and quantitative user research.

**2. Key Elements of a High-Quality Persona:**
1. **Demographic Profile:** Name, photo, age, education, occupation, location, and technical proficiency level.
2. **User Bio & Background:** Realistic narrative context explaining their daily routine and environment.
3. **Goals & Motivations:** What the user fundamentally wants to achieve (e.g., *Check college attendance and download lab manuals in under 10 seconds*).
4. **Pain Points & Frustrations:** Obstacles preventing goal achievement (e.g., *Unreliable college portals; unclear syllabus updates*).
5. **Tech Comfort & Tool Stack:** Preferred devices (Android mobile, Mac laptop) and applications used daily.
6. **Quote:** A memorable one-sentence statement summarizing their core attitude.''';

      case 5:
        return r'''### 📝 Question 5: Give Importance of User Personas in Design Thinking.

**1. Critical Importance:**
1. **Prevents "Self-Referential Design":** Stops engineers from building software based on their own personal preferences rather than actual user needs.
2. **Fosters Empathy:** Humanizes abstract data points into an understandable persona (e.g., *"Would Rahul the first-year student understand this error message?"*).
3. **Streamlines Product Prioritization:** Helps teams decide which features deliver the highest value and which can be pruned.
4. **Unifies Cross-Functional Teams:** Provides a shared reference vocabulary for developers, designers, and college administrators.
5. **Guides AI Prompt & Interface Tone:** Informs the personality, vocabulary, and conciseness required for AI chat assistants.''';

      case 6:
        return r'''### 📝 Question 6: Explain 4 W’s to Define a Problem Statement with Its Advantage.

**1. The 4 W’s Framework:**
• **1. WHO is affected?** Identifies the target user segment experiencing the difficulty (e.g., *Engineering diploma students*).
• **2. WHAT is the problem?** Defines the specific pain point and friction encountered (e.g., *Unable to quickly find subject assignments and timetable updates*).
• **3. WHERE does it happen?** Contextualizes the environment or digital surface (e.g., *On cluttered WhatsApp groups and slow legacy portals*).
• **4. WHY does it matter?** Highlights the negative impact or value lost (e.g., *Students submit assignments late and risk GTU exam disqualification*).

**2. Advantages:**
• Eliminates ambiguity by transforming vague complaints into concise, actionable problem scopes.
• Prevents proposing premature technical solutions before thoroughly understanding root causes.''';

      case 7:
        return r'''### 📝 Question 7: Explain Step by Step Process to Write a Problem Statement.

**1. Step-by-Step Process:**
1. **Step 1: Describe the Ideal State:** State how things should work ideally (e.g., *Students should have instant 24/7 access to authenticated campus documents*).
2. **Step 2: State the Current Reality & Problem:** Detail the gap between ideal and reality with empirical evidence.
3. **Step 3: Quantify the Consequences:** Explain the cost of inaction (lost study hours, missed assignment deadlines, high faculty support burden).
4. **Step 4: Draft the Point of View (POV) Formula:**
   $$\text{[User]} \text{ needs to } \text{[User’s Need]} \text{ because } \text{[Surprising Insight]}$$
5. **Step 5: Frame "How Might We" (HMW) Questions:** Convert the statement into generative design prompts (e.g., *How might we deliver verified assignment solutions to students on their mobile phones in 1 second?*).''';

      case 8:
        return r'''### 📝 Question 8: Define: Customer Journey Mapping. Explain Step by Step Process of Customer Journey Mapping.

**1. Definition:**
A **Customer Journey Map (CJM)** is a visual timeline diagram illustrating the end-to-end stages and touchpoints a user goes through to achieve a specific objective with a product, including their feelings, thoughts, and frustrations along the way.

**2. Step-by-Step Creation Process:**
1. **Set the Persona & Goal:** Select one specific persona and their designated task (e.g., *First-year student checking mid-sem syllabus*).
2. **Map the Journey Stages:** Define chronological phases: **Awareness -> Exploration -> Onboarding -> Daily Usage -> Support**.
3. **Identify Touchpoints & Actions:** Detail every interaction surface (Mobile app, college noticeboard, SMS alert, chat interface).
4. **Chart User Emotions & Friction Points:** Plot an emotional curve (Delight vs Frustration) across each step.
5. **Identify Opportunities for Improvement:** Brainstorm automated AI solutions to remove friction at the lowest dips of the journey.''';

      case 9:
        return r'''### 📝 Question 9: List Out Various Customer Journey Mapping Tools and Give Advantages of Customer Journey Mapping.

**1. Prominent Customer Journey Mapping Tools:**
• **Figma / FigJam:** Premier collaborative design and diagramming tool.
• **Miro:** Online whiteboarding platform with prebuilt CJM templates.
• **Lucidchart:** Cloud diagramming and process visualization suite.
• **Smaply:** Dedicated journey mapping and persona management software.
• **UXPressia:** Customer experience and empathy mapping platform.

**2. Advantages of Customer Journey Mapping:**
1. **360-Degree User View:** Breaks down departmental silos by mapping the entire lifecycle.
2. **Pinpoints Critical Friction Points:** Reveals precisely where users abandon apps.
3. **Informs Feature Prioritization:** Directs engineering bandwidth toward high-impact pain points.
4. **Optimizes AI Interventions:** Shows where proactive AI recommendations provide maximum relief.''';

      case 10:
        return r'''### 📝 Question 10: Explain Any Five UX Principles for AI Systems.

**1. Five Core UX Principles for AI Products (Google PAIR & Microsoft Guidelines):**
1. **Make AI Capabilities & Limitations Explicit:** Clearly communicate what the AI can do and where it might struggle, setting realistic user expectations from day one.
2. **Context-Aware Personalization:** Tailor responses dynamically based on user context (e.g., student branch, semester, previous questions) without requiring repetitive input.
3. **Graceful Failure & Recovery:** When AI is uncertain, admit limitation gracefully and provide fallback options (e.g., suggest related documents or human faculty contact) instead of hallucinating false answers.
4. **User Control & Override:** Always provide mechanisms for users to edit, correct, or dismiss AI-generated outputs easily.
5. **Transparency & Explainability (XAI):** Show sources and citations (e.g., citing the specific PDF document and chunk) so users can verify how the answer was derived.''';

      case 11:
        return r'''### 📝 Question 11: Explain Human-AI Interaction Design.

**1. Concept:**
**Human-AI Interaction Design** focuses on crafting intuitive, trustworthy, and collaborative interfaces between human users and autonomous/probabilistic artificial intelligence systems.

**2. Key Interaction Phases:**
• **Initiation (Setting Expectations):** Explain how the system uses AI and show example prompts to onboard users.
• **During Interaction (Real-Time Feedback):** Display typing indicators, progress states, and provide immediate cancellation buttons for long-running generations.
• **Post-Interaction (Evaluation & Feedback):** Provide clear copy/share buttons, thumbs-up/down ratings, and explain the rationale behind outputs.
• **When Things Go Wrong (Error Recovery):** Offer one-click retry, query reformulation suggestions, or seamless escalation to human administrators.''';

      case 12:
        return r'''### 📝 Question 12: What is Bias? Explain Main Sources of Bias in AI Systems.

**1. What is AI Bias?**
**AI Bias** occurs when an artificial intelligence system produces systematically prejudiced or unfair decisions, favoring or discriminating against certain groups due to erroneous assumptions during model training or dataset curation.

**2. Main Sources of Bias:**
1. **Historical / Societal Bias:** Real-world inequities embedded in historical training data (e.g., hiring algorithms penalizing female resumes because past hires were predominantly male).
2. **Sampling / Representation Bias:** Datasets that underrepresent specific demographics (e.g., facial recognition trained on 80% light-skinned faces failing on darker skin tones).
3. **Measurement & Labeling Bias:** Flawed human annotation where annotators inject subjective personal prejudices into data labels.
4. **Algorithmic / Optimization Bias:** Loss functions optimized purely for overall accuracy that sacrifice performance on minority edge cases.''';

      case 13:
        return r'''### 📝 Question 13: Give Conceptual Overview of Explainable AI (XAI).

**1. What is Explainable AI (XAI)?**
**Explainable AI (XAI)** is a set of methods and techniques that enable human users to understand, interpret, and trust the results and predictions generated by machine learning models, moving away from opaque "black box" systems.

```
[Black Box AI]  ──> Prediction (No explanation) ──> Low Trust ❌
[Explainable AI] ──> Prediction + "Why" Factors ──> High Trust & Compliance ✅
```

**2. Key XAI Techniques:**
• **LIME (Local Interpretable Model-agnostic Explanations):** Explains individual predictions by perturbing inputs and observing output changes.
• **SHAP (SHapley Additive exPlanations):** Calculates each feature's marginal contribution to the final decision based on cooperative game theory.
• **Feature Importance & Saliency Maps:** Visual heatmaps showing which pixels or words influenced the model's decision.

**3. Importance in Production:**
Crucial for regulatory compliance (GDPR right to explanation), debugging bias, and building user trust in high-stakes fields like healthcare, education, and finance.''';

      default:
        return _solveGenericQuestion('Artificial Intelligence & Product Development (AIPD) - Assignment 2 (Unit-2)', qNum, lang);
    }
  }

  static String _solveAiProductQuestion(String lang) {
    return r'''### 📝 Question 1: Define AI Product

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
• **P (Performance Measure):** Success metrics (e.g., Safety, Speed, Accuracy).
• **E (Environment):** Operational domain (e.g., Roads, Chess board, Hospital records).
• **A (Actuators):** Action mechanisms (e.g., Steering, Robotic arm, Display screen).
• **S (Sensors):** Input devices (e.g., Cameras, Sonar, Microphones, Keyboard).''';
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

  // =========================================================================
  // AIPE ASSIGNMENT 2 (UNIT-2) - OFFICIAL GTU QUESTIONS (GPH HIMMATNAGAR)
  // =========================================================================
  static String _solveAipeUnit2Question(int qNum, String lang) {
    switch (qNum) {
      case 1:
        return r'''### 📝 Question 1: Define LLM (Large Language Model)
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 2: Large Language Models**

---

#### 1. Definition of Large Language Model (LLM):
A **Large Language Model (LLM)** is an advanced Artificial Intelligence deep learning model built upon the **Transformer neural network architecture**. It is pre-trained on massive datasets encompassing billions to trillions of textual tokens. Armed with hundreds of millions to hundreds of billions of tunable **parameters**, an LLM possesses the capability to understand, interpret, summarize, predict, and generate human natural language with near-human fluency.

#### 2. Key Characteristics:
• **Transformer Foundation:** Leverages Multi-Head Self-Attention mechanisms to process input sequences in parallel, capturing long-range contextual dependencies between words.
• **Massive Scale & Pre-training:** Features billions of parameters (e.g., LLaMA-3 8B/70B, GPT-4) trained on web-scale text corpora.
• **Autoregressive Generation:** Predicts output token-by-token using the conditional probability distribution:
  $P(w_t \mid w_1, w_2, \dots, w_{t-1})$
• **Generalization:** Performs zero-shot and few-shot reasoning, code generation, summarization, and translation without requiring task-specific retraining.

#### 3. Core Working Stages:
1. **Tokenization:** Converts input text into discrete numeric tokens using Byte-Pair Encoding (BPE).
2. **Embedding:** Projects discrete tokens into high-dimensional continuous semantic vector spaces.
3. **Self-Attention & Transformer Layers:** Dynamically computes contextual weights across all tokens.
4. **Softmax Output:** Computes probability distribution over vocabulary to generate next words.

#### 4. Prominent Real-World Examples:
• **OpenAI GPT Series:** GPT-3.5, GPT-4, GPT-4o
• **Meta LLaMA Series:** LLaMA-2, LLaMA-3 (Open-weights foundation models)
• **Google Gemini Series:** Multimodal foundation models (Gemini Flash, Pro, Ultra)
• **Anthropic Claude Series:** Claude 3.5 Sonnet / Opus

---
💡 *Course In-Charge:* Mr. H. I. Rathod & Mr. C. D. Suthar, Lecturer in IT, Govt. Polytechnic, Himatnagar.''';

      case 2:
        return r'''### 📝 Question 2: Describe Training Data and Parameters in LLM
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 2: Large Language Models**

---

#### 1. Training Data in LLM:
• **Definition:** The massive volume of textual and code data fed into the neural network during the self-supervised pre-training phase.
• **Key Sources:**
  - *Web Crawls:* Common Crawl, Wikipedia, news articles.
  - *Books & Literature:* Public domain books, research papers (arXiv).
  - *Source Code:* Open-source GitHub repositories, technical documentation.
• **Data Curation Pipeline:**
  1. *De-duplication:* Removing redundant text to avoid model memorization.
  2. *Quality Filtering:* Removing toxic content, spam, and corrupted text.
  3. *Tokenization:* Splitting curated text into sub-word tokens (often 1 token ≈ 0.75 words).
• **Dataset Size:** Modern LLMs are trained on **1 trillion to 15+ trillion tokens** (e.g., LLaMA-3 was trained on 15T tokens).

#### 2. Parameters in LLM:
• **Definition:** The internal configurable numerical values (weights and biases) of the neural network that the model learns during the optimization and training process.
• **Significance:** Parameters store the model's factual knowledge, linguistic rules, reasoning capabilities, and stylistic nuance.
• **Parameter Scale:**
  - *Small/Edge Models:* 1B – 7B parameters (e.g., LLaMA-3 8B, Mistral 7B).
  - *Medium Models:* 13B – 70B parameters (e.g., LLaMA-3 70B).
  - *Frontier / Mega Models:* 100B – 1.8T+ parameters (e.g., GPT-4 MoE).
• **Storage & Inference:** Each parameter in FP16 precision takes 2 bytes of GPU VRAM (e.g., a 7B model requires ~14 GB of GPU RAM). Quantization (INT8 / INT4) reduces memory footprint for mobile and edge deployment.''';

      case 3:
        return r'''### 📝 Question 3: Explain Tokens and Embeddings in LLM with Suitable Example
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 2: Large Language Models**

---

#### 1. Tokens in LLMs:
• **Definition:** A **token** is the fundamental atomic unit of text that an LLM reads and processes. Tokens can represent individual characters, subwords, or entire words.
• **Tokenization Mechanism (Byte-Pair Encoding - BPE):**
  - Text is broken down into sub-word pieces to efficiently handle unseen vocabulary, prefixes, and suffixes.
  - *Rule of Thumb:* 1,000 English tokens ≈ 750 words.
• **Example:**
  - String: `"Understanding Prompt Engineering"`
  - Tokens: `["Understand", "ing", " Prompt", " Engineer", "ing"]` (5 tokens).

#### 2. Embeddings in LLMs:
• **Definition:** An **embedding** is a dense continuous numerical vector (array of floating-point numbers) in high-dimensional vector space (e.g., 768 to 4096 dimensions) that captures the semantic meaning of a token or sentence.
• **Semantic Distance (Cosine Similarity):**
  - Words with similar meanings have vectors located close together in vector space.
  - $\cos(\theta) = \frac{A \cdot B}{\|A\| \|B\|}$
• **Mathematical Vector Analogy Example:**
  $\text{Vector}(\text{"King"}) - \text{Vector}(\text{"Man"}) + \text{Vector}(\text{"Woman"}) \approx \text{Vector}(\text{"Queen"})$
• **Role in Prompt Engineering & RAG:** Embeddings convert documents and questions into vector vectors so database engines can perform fast semantic similarity search.''';

      case 4:
        return r'''### 📝 Question 4: Explain Working of LLMs with Suitable Diagram
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 2: Large Language Models**

---

#### 1. Conceptual Architecture & Workflow Diagram:
```
┌────────────────────────────────────────────────────────┐
│ 1. Raw User Prompt: "Explain photosynthesis in brief"  │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 2. Tokenizer (BPE): ["Explain", " photo", "synthesis"] │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 3. Input Embeddings + Positional Encoding Vector (RoPE)│
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 4. Stack of Transformer Decoder Blocks:                │
│    • Multi-Head Self-Attention (Masked)                │
│    • Layer Normalization & Residual Add                │
│    • Feed-Forward Network (FFN / SwiGLU)               │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 5. Linear Projection & Softmax Probability Layer       │
│    P("Photosynthesis") = 0.82, P("Plants") = 0.09...   │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 6. Next Token Generated: "Photosynthesis" (Loop back)  │
└────────────────────────────────────────────────────────┘
```

#### 2. Step-by-Step Execution:
1. **Tokenization & Positional Encoding:** Converts words to token IDs and injects position markers since Transformers process all tokens simultaneously.
2. **Multi-Head Self-Attention:** Computes how much attention every word should pay to all other words in the prompt via Query ($Q$), Key ($K$), and Value ($V$) matrices:
   $\text{Attention}(Q, K, V) = \text{softmax}\left(\frac{QK^T}{\sqrt{d_k}}\right)V$
3. **Feed-Forward Layers:** Non-linear transformations extract high-level conceptual relationships.
4. **Softmax & Autoregressive Decoding:** Determines the next word, appends it to the sequence, and repeats until the End-of-Sequence (`<EOS>`) token is emitted.''';

      case 5:
        return r'''### 📝 Question 5: Write Note on Following LLMs: GPT and Llama
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 2: Large Language Models**

---

#### 1. GPT (Generative Pre-trained Transformer) - OpenAI:
• **Developer:** OpenAI (San Francisco, USA).
• **Architecture:** Proprietary, closed-weights decoder-only transformer.
• **Evolution:**
  - *GPT-1 (2018):* 117M parameters, proved pretraining + fine-tuning works.
  - *GPT-2 (2019):* 1.5B parameters, demonstrated zero-shot capabilities.
  - *GPT-3 (2020):* 175B parameters, revolutionized in-context learning.
  - *GPT-4 & GPT-4o (2023-2024):* Multimodal frontier model with Mixture-of-Experts (MoE).
• **Training Paradigm:** Trained via Unsupervised Pretraining on web text + Supervised Fine-Tuning (SFT) + Reinforcement Learning from Human Feedback (RLHF).
• **Access:** Closed-source; accessed via web interface (ChatGPT) or OpenAI REST API.

#### 2. LLaMA (Large Language Model Meta AI) - Meta:
• **Developer:** Meta AI (Mark Zuckerberg / Yann LeCun team).
• **Architecture:** Open-weights foundation model designed for research and commercial deployment.
• **Key Architectural Enhancements:**
  - Uses **SwiGLU** activation functions instead of standard ReLU.
  - Employs **Rotary Position Embeddings (RoPE)** for superior context length scaling.
  - Implements **RMSNorm** (Root Mean Square Normalization) for stable training.
• **Evolution:**
  - *LLaMA-1 (2023):* 7B to 65B parameters, outperformed GPT-3 despite smaller size.
  - *LLaMA-2 (2023):* Doubled context length, commercially licensed.
  - *LLaMA-3 / 3.1 / 3.3 (2024):* 8B, 70B, and 405B parameters trained on 15+ trillion tokens, state-of-the-art open model competing directly with GPT-4.
• **Access:** Open-weights; can be downloaded, fine-tuned privately on local servers, and run offline using Ollama or vLLM.''';

      case 6:
        return r'''### 📝 Question 6: Explain Capabilities and Limitations of LLMs
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 2: Large Language Models**

---

#### 1. Core Capabilities of LLMs:
1. **Natural Language Understanding & Generation:** Produces grammatically perfect, contextually relevant human-like writing across essays, reports, and emails.
2. **Multilingual Translation:** High-accuracy translation across hundreds of languages including regional Indian languages (Hindi, Gujarati, Tamil).
3. **Code Synthesis & Debugging:** Writes, explains, refactors, and debugs code across Python, Dart, JavaScript, C++, and SQL.
4. **Text Summarization & Extraction:** Condenses multi-page research documents and extracts structured JSON/CSV data.
5. **In-Context Few-Shot Learning:** Adapts to novel tasks on the fly simply by reading 2-3 examples inside the prompt without weight updates.

#### 2. Inherent Limitations of LLMs:
1. **Hallucination:** Generating false, fictitious facts or fake citations with absolute confidence.
2. **Knowledge Cutoff:** Lack of real-time awareness beyond the date the pre-training dataset was compiled (unless augmented with RAG or web search).
3. **Stochastic Nature (Lack of True Common-Sense Reasoning):** LLMs are probabilistic pattern matchers, not conscious logic engines; they struggle with multi-step symbolic arithmetic.
4. **Resource & Inference Cost:** Deploying and querying large models requires expensive enterprise GPUs (Nvidia H100/A100) and substantial electricity.
5. **Security Vulnerabilities:** Susceptible to Prompt Injection attacks, jailbreaks, and sensitive training data leakage.''';

      case 7:
        return r'''### 📝 Question 7: Explain Hallucination in LLM and Methods to Reduce It
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 2: Large Language Models**

---

#### 1. What is Hallucination in LLM?
• **Definition:** **Hallucination** occurs when a Large Language Model generates text that sounds authoritative, logical, and confident, but is factually false, ungrounded, fabricated, or contradicts verified facts.
• **Types:**
  - *Extrinsic Hallucination:* Output introduces information not present or supported anywhere in the input context.
  - *Intrinsic Hallucination:* Output directly contradicts the factual source text provided in the prompt.
• **Root Cause:** LLMs do not "know" truth; they optimize purely for the highest conditional mathematical probability of the next token based on statistical patterns.

#### 2. Proven Engineering Methods to Reduce Hallucination:
1. **Retrieval-Augmented Generation (RAG):**
   - Retrieve verified factual documents from a local vector database and inject them into the prompt as strict reference material.
   - Instruct the model: *"Answer strictly and ONLY from the provided context below. If not present, state 'I do not have this information'."*
2. **Chain-of-Thought (CoT) Prompting:**
   - Ask the model to *"Think step-by-step and write your logical deduction before reaching the final conclusion."* This forces intermediate consistency checks.
3. **Lowering Decoding Temperature:**
   - Set `temperature = 0.0` or `0.2`. Lower temperatures minimize creative randomness and enforce greedy, deterministic factual outputs.
4. **Few-Shot Demonstration Grounding:**
   - Provide explicit input-output examples demonstrating fact-checking, citations, and polite refusals for unsupported queries.
5. **Human-in-the-Loop & Verification Pipelines:**
   - Cross-check outputs using automated guardrail models (e.g., Llama Guard, NeMo Guardrails) before presenting answers to end users.''';

      case 8:
        return r'''### 📝 Question 8: Describe Different Types of Cost Associated with LLM
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 2: Large Language Models**

---

#### 1. The Four Primary Cost Dimensions of LLMs:
1. **Pre-Training Cost (Capital Expenditure):**
   - *Hardware Clusters:* Thousands of high-end GPUs (e.g., 16,000+ Nvidia H100 GPUs) running continuously for 3 to 6 months.
   - *Electricity & Cooling:* Megawatts of power consumption running into millions of dollars.
   - *Data Acquisition & Curation:* Buying licensed corpora, cleaning, and filtering trillions of tokens.
   - *Total Cost:* Training a frontier model (GPT-4 / LLaMA-3 405B) exceeds **\$50M – \$100M+ USD**.

2. **Fine-Tuning & Alignment Cost:**
   - *Domain Adaptation:* Training on curated enterprise domain datasets using LoRA / QLoRA techniques.
   - *Human Annotation for RLHF:* Paying skilled human reviewers and subject-matter experts to write and rank thousands of model responses for safety and accuracy.

3. **Inference & Operational Cost (API Billing / Cloud Hosting):**
   - *Token-Based API Pricing:* Cloud providers charge per 1 Million tokens (e.g., input tokens vs output tokens).
   - *Dedicated GPU Cloud Hosting:* Renting cloud GPU instances (AWS, Azure, RunPod) costing \$2 – \$4 per GPU-hour.
   - *Memory Footprint:* Running 70B models requires multi-GPU nodes with 160GB+ VRAM.

4. **Integration, Engineering & Maintenance Cost:**
   - *Vector Database & RAG Infrastructure:* Pinecone, pgvector, Supabase hosting costs.
   - *Prompt Engineering & Continuous Evaluation:* Engineering hours spent testing, optimizing prompts, evaluating drift, and building safety guardrails.''';

      default:
        return _solveGenericQuestion('Artificial Intelligence with Prompt Engineering (AIPE) - Assignment 2 (Unit-2)', qNum, lang);
    }
  }

  // =========================================================================
  // AIPE ASSIGNMENT 1 (UNIT-1) - OFFICIAL GTU QUESTIONS (GPH HIMMATNAGAR)
  // =========================================================================
  static String _solveAipeUnit1Question(int qNum, String lang) {
    switch (qNum) {
      case 1:
        return r'''### 📝 Question 1: Define AI and Write Its Applications
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 1**

---

#### 1. Definition of Artificial Intelligence (AI):
**Artificial Intelligence (AI)** is the branch of computer science dedicated to creating hardware and software systems capable of performing tasks that traditionally require human intelligence—such as visual perception, natural language understanding, speech recognition, decision-making, and autonomous problem-solving.

#### 2. Key Applications of AI:
1. **Healthcare & Medicine:** Early tumor detection via computer vision, automated radiology scans, drug discovery, and robot-assisted surgery.
2. **Automotive & Autonomous Systems:** Self-driving vehicles (Tesla, Waymo) utilizing sensor fusion and real-time obstacle detection.
3. **Finance & Banking:** Algorithmic stock trading, automated credit scoring, fraud detection, and anti-money laundering (AML).
4. **Education & Academics:** Personalized adaptive learning platforms, automated grading, intelligent campus chatbots.
5. **E-Commerce & Entertainment:** Recommendation algorithms (Netflix, Amazon, YouTube), automated inventory forecasting.
6. **Cybersecurity:** Real-time threat detection, anomaly detection, and automated intrusion prevention systems.''';

      case 2:
        return r'''### 📝 Question 2: Write the Differences Between AI, ML, and DL
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 1**

---

#### 1. Comparison Matrix:
| Parameter | Artificial Intelligence (AI) | Machine Learning (ML) | Deep Learning (DL) |
| :--- | :--- | :--- | :--- |
| **Scope** | Broadest umbrella discipline simulating human cognition. | Subset of AI focused on learning patterns from data. | Subset of ML using deep multi-layered neural networks. |
| **Core Method** | Rule engines, heuristics, knowledge graphs, and learning algorithms. | Statistical algorithms (Linear Regression, Decision Trees, SVM). | Artificial Neural Networks (CNN, RNN, Transformers). |
| **Feature Extraction**| Handcrafted manually or hard-coded by programmers. | Manually engineered features selected by domain experts. | Automatically learns hierarchical features from raw data. |
| **Data Dependency** | Works on small rules or large data systems. | Performs effectively on medium-sized structured datasets. | Requires vast amounts of labeled/unlabeled big data. |
| **Hardware** | Standard CPUs. | Standard CPUs and multi-core systems. | Heavy reliance on high-performance GPUs / TPUs. |
| **Example** | Chess engine, Siri, Expert Systems. | Spam email filter, house price prediction. | Facial recognition, GPT-4, autonomous driving. |''';

      case 3:
        return r'''### 📝 Question 3: Discuss Narrow AI and General AI in Detail
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 1**

---

#### 1. Narrow AI (Weak AI):
• **Definition:** AI systems designed, trained, and optimized to execute a specific, dedicated task or a bounded set of related tasks.
• **Characteristics:** Highly proficient in their specific domain but completely incapable of transferring knowledge or operating outside their programmed boundaries.
• **Status:** **All existing AI systems today are Narrow AI.**
• **Examples:** AlphaGo (plays Go masterfully but cannot play chess or speak English), Apple Siri, spam filters, face recognition unlock.

#### 2. General AI (Artificial General Intelligence - AGI / Strong AI):
• **Definition:** A hypothetical level of AI that possesses generalized human cognitive abilities—capable of understanding, learning, reasoning, abstracting, and applying intelligence across any intellectual task just like a human being.
• **Characteristics:** Autonomous transfer learning, emotional and contextual awareness, self-awareness, and multi-domain problem-solving.
• **Status:** Currently **theoretical**; actively researched by OpenAI, Google DeepMind, and Anthropic.
• **Key Difference:** Narrow AI excels at 1 task; General AI can learn any intellectual task a human can do.''';

      case 4:
        return r'''### 📝 Question 4: Explain the Concept of Generative AI with Suitable Examples
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 1**

---

#### 1. Concept of Generative AI:
**Generative AI (GenAI)** refers to AI models that create new, original content (text, images, audio, video, synthetic data, code) rather than merely analyzing, labeling, or classifying existing data.
• **Working Principle:** Learns the underlying probability distribution $P(X)$ of large training corpora and generates novel samples drawn from that learned distribution.
• **Distinction from Discriminative AI:**
  - *Discriminative:* Computes $P(Y \mid X)$ (e.g. "Is this picture a cat or a dog?").
  - *Generative:* Models $P(X)$ (e.g. "Draw a brand-new, realistic picture of a cat sitting on a laptop.").

#### 2. Suitable Real-World Examples:
1. **Text Generation:** ChatGPT, Claude drafting academic essays, stories, or technical reports.
2. **Image Synthesis:** Midjourney, DALL-E 3 generating photorealistic images from textual prompts.
3. **Code Generation:** GitHub Copilot converting natural language comments into working Python/Dart functions.
4. **Audio & Voice Cloning:** ElevenLabs generating realistic spoken voice from written text.
5. **Video Generation:** OpenAI Sora generating cinematic 60-second video clips from text descriptions.''';

      case 5:
        return r'''### 📝 Question 5: Discuss Different Types of Generative AI Systems
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 1**

---

#### 1. Modality-Based Classification of Generative AI:
1. **Text-to-Text Generative Systems:**
   - Ingest natural language prompts and produce fluent textual responses, summaries, code, and explanations.
   - *Architecture:* Decoder-only Transformers (GPT-4, LLaMA-3).
2. **Text-to-Image Generative Systems:**
   - Ingest descriptive prompts and generate high-resolution synthetic artwork and photorealistic graphics.
   - *Architecture:* Latent Diffusion Models (Stable Diffusion, Midjourney, DALL-E 3).
3. **Text-to-Audio & Speech Systems:**
   - Convert text into emotional speech audio or generate original musical compositions.
   - *Architecture:* Tacotron, WaveNet, Suno AI.
4. **Text-to-Video Systems:**
   - Generate multi-second coherent video scenes with consistent physics and motion.
   - *Architecture:* Diffusion Transformers (Sora, Runway Gen-3).
5. **Text-to-Code Systems:**
   - Specialized code generation, documentation, and automated test synthesis.
   - *Architecture:* CodeLlama, GitHub Copilot.''';

      case 6:
        return r'''### 📝 Question 6: Explain Features and Applications of Generative AI Tools: ChatGPT, Gemini, and DALL-E
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 1**

---

#### 1. ChatGPT (OpenAI):
• **Features:** Conversational fluency, multi-turn memory retention, advanced code execution sandbox, custom GPTs, file analysis.
• **Applications:** Customer support automation, academic tutoring, software code generation, essay writing.

#### 2. Gemini (Google):
• **Features:** Natively multimodal from the ground up (understands video, audio, image, and text simultaneously in a single prompt), massive 1M+ token context window, seamless integration with Google Workspace (Docs, Gmail, Drive).
• **Applications:** Multimodal document analysis, long video summarization, real-time voice conversations.

#### 3. DALL-E (OpenAI):
• **Features:** High prompt fidelity, text rendering inside images, iterative editing and inpainting/outpainting.
• **Applications:** Marketing visuals, website banner creation, digital art prototyping, product design mockups.''';

      case 7:
        return r'''### 📝 Question 7: Explain the Concept of Natural Language Processing (NLP) with Examples
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 1**

---

#### 1. Concept of Natural Language Processing (NLP):
**Natural Language Processing (NLP)** is the subfield of AI and computational linguistics that enables computers to read, interpret, understand, and generate human languages in a valuable, contextual manner.

#### 2. Core NLP Tasks & Examples:
1. **Tokenization & Lemmatization:** Breaking sentences into words and reducing words to base dictionary forms (e.g., `"running"`, `"ran"` $\to$ `"run"`).
2. **Part-of-Speech (POS) Tagging:** Identifying nouns, verbs, adjectives.
3. **Named Entity Recognition (NER):** Extracting people, organizations, dates (e.g., *"Sundar Pichai [PERSON] leads Google [ORG] in California [LOC]"*).
4. **Sentiment Analysis:** Classifying customer reviews as Positive, Neutral, or Negative (e.g., *"Food was amazing!"* $\to$ 95% Positive).
5. **Machine Translation:** Translating English text into Gujarati or Hindi (e.g., Google Translate).''';

      case 8:
        return r'''### 📝 Question 8: Discuss the Role of NLP in Chatbots and Large Language Models
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 1**

---

#### 1. Role in Chatbots:
• **Intent Recognition:** NLP classifies user queries to determine the intended action (e.g., identifying whether the student wants a timetable, lab manual, or attendance report).
• **Entity Extraction:** Pulls parameters like subject name, unit number, date, or enrollment ID from informal sentences.
• **Dialogue State Tracking:** Keeps track of previous context across multi-turn user conversations.

#### 2. Role in Large Language Models (LLMs):
• **Input Tokenization & Embeddings:** Converts raw alphabetic characters into mathematical vectors representing semantic nuance.
• **Self-Attention Mechanism:** Models grammatical rules, idiomatic expressions, and semantic context across thousands of words.
• **Human Preference Alignment:** NLP benchmarks (HELM, MMLU) and techniques like RLHF evaluate safety, helpfulness, and factual coherence.''';

      default:
        return _solveGenericQuestion('Artificial Intelligence with Prompt Engineering (AIPE) - Assignment 1 (Unit-1)', qNum, lang);
    }
  }

  // =========================================================================
  // AIPE ASSIGNMENT 3 (UNIT-3) - OFFICIAL GTU QUESTIONS (GPH HIMMATNAGAR)
  // =========================================================================
  static String _solveAipeUnit3Question(int qNum, String lang) {
    switch (qNum) {
      case 1:
        return r'''### 📝 Question 1: Define Prompt and Prompt Engineering
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 3: Prompt Engineering Fundamentals**

---

#### 1. Definition of Prompt:
A **Prompt** is the specific text, instruction, question, code snippet, or contextual input provided by a user to a Generative AI model or Large Language Model (LLM) to elicit a desired output or response.

#### 2. Definition of Prompt Engineering:
**Prompt Engineering** is the strategic discipline, process, and art of designing, refining, structuring, and optimizing input prompts to guide an LLM toward producing accurate, relevant, safe, and high-quality responses with minimal hallucination.
• *Significance:* Enables developers and users to harness the full reasoning and generative capabilities of LLMs without changing underlying model weights.''';

      case 2:
        return r'''### 📝 Question 2: Explain Prompt Lifecycle with Suitable Diagram
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 3: Prompt Engineering Fundamentals**

---

#### 1. Prompt Lifecycle Diagram:
```
┌────────────────────────────────────────────────────────┐
│ 1. Define Goal & Requirements (Task, Persona, Tone)    │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 2. Design Initial Prompt (Instructions, Context, Data) │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 3. Execute & Test with LLM                             │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 4. Evaluate Output (Accuracy, Hallucination, Format)   │
└──────────────────────────┬─────────────────────────────┘
                           │
              ┌────────────┴────────────┐
              ▼                         ▼
      [Does not meet SLA]       [Meets Goal]
              │                         │
              ▼                         ▼
┌──────────────────────────┐  ┌──────────────────────────┐
│ 5. Refine & Iterate      │  │ 6. Deploy & Monitor      │
│ (Add constraints, shots) │  │ (Logging, Guardrails)    │
└─────────────┬────────────┘  └──────────────────────────┘
              │                         ▲
              └─────────────────────────┘
```

#### 2. Stages Explained:
1. **Define Goal:** Establish output format (JSON, Markdown, bullet points), target audience, and required facts.
2. **Drafting Initial Prompt:** Combine role definition, primary directive, and input variables.
3. **Execution & Testing:** Run prompt against various model parameters (temperature, top_p).
4. **Evaluation:** Check for logical errors, factual accuracy, and format adherence.
5. **Iterative Refinement:** Add negative constraints, few-shot examples, or Chain-of-Thought directives.
6. **Deployment & Continuous Monitoring:** Integrate into application code and monitor for drift.''';

      case 3:
        return r'''### 📝 Question 3: Describe the Structure of the Prompt
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 3: Prompt Engineering Fundamentals**

---

#### 1. Key Structural Components of an Effective Prompt:
1. **Persona / Role:** Assigns expertise to the model (e.g., *"You are a senior GTU IT professor and academic advisor."*).
2. **Instruction / Task:** Clear, imperative verb stating exactly what the AI must do (e.g., *"Explain the working of transformers."*).
3. **Context / Background:** Relevant reference documents, constraints, or historical context (e.g., *"For final-year diploma engineering students preparing for semester exams."*).
4. **Input Data:** The specific content to process (e.g., raw code, article excerpt, student question).
5. **Output Format / Constraints:** Exact desired output schema (e.g., *"Format as clean Markdown with numbered headings, comparison table, and bullet points. Do not exceed 300 words."*).''';

      case 4:
        return r'''### 📝 Question 4: Explain Prompting Methods and Their Advantages with Suitable Example Prompts
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 3: Prompt Engineering Fundamentals**

---

#### 1. Zero-Shot Prompting:
• **Concept:** The model is given an instruction without any examples and asked to solve the task directly using pre-trained knowledge.
• **Example Prompt:** *"Classify the sentiment of this review: 'The battery drains in 2 hours.' Output: [Positive / Negative]"*
• **Advantage:** Fast, token-efficient, simple.

#### 2. Few-Shot Prompting:
• **Concept:** Provides 2 to 5 demonstration input-output pairs to show the model the desired pattern and format before the target question.
• **Example Prompt:**
  ```
  Review: "Camera quality is breathtaking!" -> Sentiment: Positive
  Review: "Delivery took 3 weeks." -> Sentiment: Negative
  Review: "Screen resolution is crystal clear." -> Sentiment:
  ```
• **Advantage:** Drastically improves output consistency and format adherence.

#### 3. Role-Based Prompting:
• **Concept:** Assigns a specialized persona or identity to frame the perspective, vocabulary, and depth of the response.
• **Example Prompt:** *"Act as a cybersecurity expert and explain SQL Injection to a first-year programming student."*
• **Advantage:** Sets appropriate tone, depth, and terminology tailored to the audience.''';

      case 5:
        return r'''### 📝 Question 5: Write the Process of Writing Effective Prompts and Its Advantages
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 3: Prompt Engineering Fundamentals**

---

#### 1. Systematic Process for Crafting Effective Prompts:
1. **Be Specific and Clear:** Avoid vague queries; use direct verbs (*Explain*, *Compare*, *List*, *Summarize*).
2. **Provide Context:** Frame the target user level, domain, and objective.
3. **Specify Constraints & Format:** Explicitly define output format (JSON, Markdown table, bulleted list).
4. **Use Delimiters:** Enclose reference text within triple quotes (`"""`) or markdown blocks to prevent prompt confusion.
5. **Direct Negative Constraints:** State what NOT to do (e.g., *"Do not include personal opinions or introductory filler text."*).

#### 2. Advantages:
• Drastically reduces model hallucinations.
• Ensures predictable, parseable responses for software integrations.
• Saves API token cost by avoiding lengthy conversational follow-ups.''';

      case 6:
        return r'''### 📝 Question 6: Write a Note on Prompt Testing and Evaluation
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 3: Prompt Engineering Fundamentals**

---

#### 1. Prompt Testing:
• Involves testing prompt behavior across diverse test cases (typical cases, edge cases, adversarial prompt injection attempts).
• Evaluates model outputs across different temperature settings (0.0 for deterministic vs 0.7 for creative).

#### 2. Evaluation Metrics:
1. **Accuracy & Factuality:** Verification against ground-truth benchmarks.
2. **Format Adherence:** Programmatic JSON schema validation.
3. **Latency & Token Usage:** Measuring inference speed and cost.
4. **Safety & Toxicity:** Checking compliance with safety guardrails.''';

      default:
        return _solveGenericQuestion('Artificial Intelligence with Prompt Engineering (AIPE) - Assignment 3 (Unit-3)', qNum, lang);
    }
  }

  // =========================================================================
  // AIPE ASSIGNMENT 4 (UNIT-4) - OFFICIAL GTU QUESTIONS (GPH HIMMATNAGAR)
  // =========================================================================
  static String _solveAipeUnit4Question(int qNum, String lang) {
    switch (qNum) {
      case 1:
        return r'''### 📝 Question 1: Describe Following Prompting Techniques with Suitable Examples
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 4: Advanced Prompting & RAG**

---

#### 1. Chain-of-Thought (CoT) Prompting:
• **Concept:** Prompts the LLM to generate intermediate reasoning steps before arriving at the final answer.
• **Example:** *"A farmer has 15 sheep. All but 8 die. How many are left? Think step-by-step before answering."*

#### 2. Prompt Chaining:
• **Concept:** Breaking a complex task into multiple sequential prompts where the output of Prompt 1 becomes the input for Prompt 2.
• **Example:** Prompt 1: Summarize customer feedback -> Prompt 2: Extract top 3 feature requests from the summary -> Prompt 3: Draft GitHub issues for each request.

#### 3. Self-Consistency Prompting:
• **Concept:** Samples multiple diverse reasoning paths from the model at temperature > 0 and selects the majority answer.
• **Advantage:** Boosts accuracy on complex mathematical and symbolic reasoning problems.

#### 4. ReAct (Reason + Act) Prompting:
• **Concept:** Combines reasoning traces with task-specific actions (searching databases, calling APIs, executing calculators) in an interactive feedback loop.''';

      case 2:
        return r'''### 📝 Question 2: Prompt Design for Summarization, Code Generation, Q&A, and Translation
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 4: Advanced Prompting & RAG**

---

#### 1. Text Summarization:
• *Design:* Define maximum length, target audience, and key takeaway bullets.
• *Prompt Example:* *"Summarize the following research paper into 3 executive bullet points under 100 words: """[Insert Text]""""*

#### 2. Code Generation:
• *Design:* Specify programming language, framework version, edge-case handling, and documentation comments.
• *Prompt Example:* *"Write a Flutter Dart function using Riverpod that performs async login with error handling. Include doc comments."*

#### 3. Question Answering (Q&A):
• *Design:* Ground answer strictly in provided context to eliminate hallucination.
• *Prompt Example:* *"Answer the question strictly from the provided campus notice below. If unknown, state 'Information not found.'"""[Notice]""""*

#### 4. Language Translation:
• *Design:* Preserve cultural idioms and technical terminology accurately.
• *Prompt Example:* *"Translate the following college circular from English to formal Gujarati, keeping technical terms in English brackets."*''';

      case 3:
        return r'''### 📝 Question 3: Concept and Basic Architecture of Retrieval Augmented Generation (RAG) with Diagram
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 4: Advanced Prompting & RAG**

---

#### 1. Concept of RAG:
**Retrieval-Augmented Generation (RAG)** is an AI framework that augments an LLM's prompt with authoritative facts retrieved dynamically from external knowledge bases (PDFs, relational databases, vector stores) before generating an answer.

#### 2. Architecture Diagram:
```
┌────────────────────────────────────────────────────────┐
│ 1. User Query: "When is the AIPE Mid-Sem Exam?"        │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 2. Embed Query (Vector Embedding Model)                │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 3. Semantic Vector Search in Database (Supabase / RAG) │
│    Matched Chunk: "AIPE Exam: 28-09-2026 11:30 AM"     │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 4. Augmented Prompt Injected into LLM:                 │
│    "Context: [AIPE Exam 28-09-2026] Question: [...]"   │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 5. Accurate, Zero-Hallucination Verified Response      │
└────────────────────────────────────────────────────────┘
```''';

      case 4:
        return r'''### 📝 Question 4: Explain Use of External Knowledge Sources in RAG
**Subject:** Artificial Intelligence with Prompt Engineering (AIPE - DI05016011) | **Unit 4: Advanced Prompting & RAG**

---

#### 1. Why External Knowledge Sources are Essential:
1. **Eliminates Hallucination:** Forces the LLM to ground its assertions in verified corporate or academic records.
2. **Overcomes Knowledge Cutoff:** Provides live, updated data (e.g. current semester timetables, circulars) without costly model retraining.
3. **Data Security & Privacy:** Proprietary campus documents remain secured inside local databases rather than being baked into public LLM training weights.
4. **Source Attribution:** Allows the system to cite specific document pages and attach downloadable PDF files for verification.''';

      default:
        return _solveGenericQuestion('Artificial Intelligence with Prompt Engineering (AIPE) - Assignment 4 (Unit-4)', qNum, lang);
    }
  }

  // =========================================================================
  // CDCT ASSIGNMENTS (UNITS 2, 3, 4) - OFFICIAL GTU QUESTIONS (GPH HIMMATNAGAR)
  // =========================================================================
  static String _solveCdctUnit2Question(int qNum, String lang) {
    switch (qNum) {
      case 1:
        return r'''### 📝 Question 1: Define Virtualization, Characteristics, and Advantages
**Subject:** Cloud and Data Center Technology (CDCT - DI05016031) | **Unit 2: Virtualization and Hypervisors**

---

#### 1. Definition of Virtualization:
**Virtualization** is the fundamental cloud technology that abstracts physical hardware resources (CPU, Memory, Storage, Network) to create multiple simulated virtual environments or dedicated Virtual Machines (VMs) on a single physical host machine.

#### 2. Key Characteristics:
• **Partitioning:** Running multiple operating systems on one physical machine simultaneously.
• **Isolation:** Fault and security isolation; a failure in one VM does not crash neighboring VMs.
• **Encapsulation:** Complete VM state is saved as a single file, making migration effortless.
• **Hardware Independence:** VMs can run on any physical host without driver incompatibilities.

#### 3. Advantages:
• Maximizes hardware server utilization (from 15% to 80%+).
• Reduces hardware, data center floor space, and cooling power costs.
• Rapid provisioning of new servers in minutes instead of weeks.''';

      case 5:
        return r'''### 📝 Question 5: Explain Hypervisor with Its Types
**Subject:** Cloud and Data Center Technology (CDCT - DI05016031) | **Unit 2: Virtualization and Hypervisors**

---

#### 1. What is a Hypervisor?
A **Hypervisor** (or Virtual Machine Monitor - VMM) is specialized software, firmware, or low-level operating code that creates, manages, and executes virtual machines by allocating underlying hardware resources.

#### 2. Types of Hypervisors:
1. **Type-1 Hypervisor (Bare-Metal / Native):**
   - Runs directly on the host computer's physical hardware without an underlying operating system.
   - *Characteristics:* High performance, enterprise-grade, low latency, robust security.
   - *Examples:* VMware ESXi, Microsoft Hyper-V, Citrix XenServer, KVM.
2. **Type-2 Hypervisor (Hosted):**
   - Runs on top of a conventional host operating system as an application software.
   - *Characteristics:* Slower performance due to OS overhead; used primarily for desktop testing and development.
   - *Examples:* Oracle VirtualBox, VMware Workstation.''';

      default:
        return '''### 📝 Question $qNum: Virtualization & Hypervisors (CDCT Unit 2)
• **Full Virtualization:** Complete hardware simulation allowing unmodified guest operating systems.
• **Para-Virtualization:** Guest OS is modified to communicate directly with the hypervisor via hypercalls for superior performance.
• **OS-Level Virtualization:** Containers (Docker) sharing host OS kernel for lightweight execution.''';
    }
  }

  static String _solveCdctUnit3Question(int qNum, String lang) {
    return '''### 📝 Question $qNum: Data Center Architecture (CDCT Unit 3)
• **Data Center:** A centralized physical facility housing compute servers, storage systems, and network infrastructure supporting enterprise applications.
• **Topologies:** Three-Tier architecture (Core, Aggregation, Access) and modern Spine-and-Leaf architecture for low-latency East-West cloud traffic.
• **Cloud Scalability vs Elasticity:**
  - *Scalability:* System's ability to handle growing workloads by adding resources (Scale-up or Scale-out).
  - *Elasticity:* Ability to automatically expand and shrink resources dynamically based on real-time load.''';
  }

  static String _solveCdctUnit4Question(int qNum, String lang) {
    return '''### 📝 Question $qNum: Cloud Storage & Database Services (CDCT Unit 4)
• **Cloud Storage Types:**
  - *Block Storage:* Fast raw volumes for OS and databases (e.g., AWS EBS).
  - *File Storage:* Shared hierarchical file systems via NFS/SMB (e.g., AWS EFS).
  - *Object Storage:* Highly durable unstructured storage accessible via HTTP REST API (e.g., AWS S3, Supabase Storage).
• **Consistency vs Durability:**
  - *Consistency:* Ensures all read operations return the most recent write.
  - *Durability:* Ensures committed data is permanently preserved without corruption (99.999999999% durability).''';
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

  // -------------------------------------------------------------------------
  // OFFICIAL GTU MID-SEMESTER EXAMINATION SCHEDULE SOLVER
  // -------------------------------------------------------------------------
  static String getExamScheduleResponse({
    required String userText,
    required String language,
    String? specificSubject,
  }) {
    final bool isGujarati = language == 'GUJARATI';
    final lower = userText.toLowerCase();

    String? sub = specificSubject;
    if (sub == null) {
      if (lower.contains('aipd') || lower.contains('product design') || lower.contains('product development') || lower.contains('ai product')) {
        sub = 'aipd';
      } else if (lower.contains('aipe') || lower.contains('prompt engineering') || lower.contains('prompt')) {
        sub = 'aipe';
      } else if (lower.contains('cdct') || lower.contains('cloud') || lower.contains('data center') || lower.contains('cyber') || lower.contains('security')) {
        sub = 'cdct';
      } else if (lower.contains('fbc') || lower.contains('blockchain') || lower.contains('foundation of blockchain')) {
        sub = 'fbc';
      }
    }

    final buffer = StringBuffer();

    if (sub != null) {
      if (isGujarati) {
        switch (sub) {
          case 'aipd':
            buffer.writeln('🎯 **AI Product Design (AIPD - DI05016021)** પરીક્ષા:\n• 📅 **તારીખ:** **મંગળવાર, 29-09-2026**\n• ⏰ **સમય:** **સવારે 11:30 થી બપોરે 12:30**\n• 🏫 **વિભાગ:** ઇન્ફોર્મેશન ટેકનોલોજી (સેમેસ્ટર 5)\n');
            break;
          case 'aipe':
            buffer.writeln('🎯 **Artificial Intelligence with Prompt Engineering (AIPE - DI05016011)** પરીક્ષા:\n• 📅 **તારીખ:** **સોમવાર, 28-09-2026**\n• ⏰ **સમય:** **સવારે 11:30 થી બપોરે 12:30**\n• 🏫 **વિભાગ:** ઇન્ફોર્મેશન ટેકનોલોજી (સેમેસ્ટર 5)\n');
            break;
          case 'cdct':
            buffer.writeln('🎯 **Cloud and Data Center Technology (CDCT - DI05016031)** પરીક્ષા:\n• 📅 **તારીખ:** **બુધવાર, 30-09-2026**\n• ⏰ **સમય:** **સવારે 11:30 થી બપોરે 12:30**\n• 🏫 **વિભાગ:** ઇન્ફોર્મેશન ટેકનોલોજી (સેમેસ્ટર 5)\n');
            break;
          case 'fbc':
            buffer.writeln('🎯 **Foundation of Blockchain (FBC - DI05016051)** પરીક્ષા:\n• 📅 **તારીખ:** **ગુરુવાર, 01-10-2026**\n• ⏰ **સમય:** **સવારે 11:30 થી બપોરે 12:30**\n• 🏫 **વિભાગ:** ઇન્ફોર્મેશન ટેકનોલોજી (સેમેસ્ટર 5)\n');
            break;
        }
      } else {
        switch (sub) {
          case 'aipd':
            buffer.writeln('🎯 **AI Product Design (AIPD - DI05016021)** Mid-Sem Exam:\n• 📅 **Date:** **Tuesday, 29-09-2026**\n• ⏰ **Timing:** **11:30 AM – 12:30 PM**\n• 🏫 **Department:** Information Technology (Sem 5)\n');
            break;
          case 'aipe':
            buffer.writeln('🎯 **Artificial Intelligence with Prompt Engineering (AIPE - DI05016011)** Mid-Sem Exam:\n• 📅 **Date:** **Monday, 28-09-2026**\n• ⏰ **Timing:** **11:30 AM – 12:30 PM**\n• 🏫 **Department:** Information Technology (Sem 5)\n');
            break;
          case 'cdct':
            buffer.writeln('🎯 **Cloud and Data Center Technology (CDCT - DI05016031)** Mid-Sem Exam:\n• 📅 **Date:** **Wednesday, 30-09-2026**\n• ⏰ **Timing:** **11:30 AM – 12:30 PM**\n• 🏫 **Department:** Information Technology (Sem 5)\n');
            break;
          case 'fbc':
            buffer.writeln('🎯 **Foundation of Blockchain (FBC - DI05016051)** Mid-Sem Exam:\n• 📅 **Date:** **Thursday, 01-10-2026**\n• ⏰ **Timing:** **11:30 AM – 12:30 PM**\n• 🏫 **Department:** Information Technology (Sem 5)\n');
            break;
        }
      }
    }

    if (isGujarati) {
      buffer.writeln('📅 **ઇન્ફોર્મેશન ટેકનોલોજી (IT) — સેમેસ્ટર 5 મિડ-સેમ પરીક્ષા ટાઈમટેબલ / સમયપત્રક (Winter 2026)**\n');
      buffer.writeln('⏰ **પરીક્ષા સમય: સવારે 11:30 થી બપોરે 12:30**');
      buffer.writeln('🏫 **કોલેજ:** ગવર્નમેન્ટ પોલિટેકનિક, હિંમતનગર\n');
      buffer.writeln('| તારીખ | વાર | વિષય | વિષય કોડ | સમય |');
      buffer.writeln('| :--- | :--- | :--- | :--- | :--- |');
      buffer.writeln('| **28-09-2026** | સોમવાર | Artificial Intelligence with Prompt Engineering (AIPE) | DI05016011 | 11:30 AM – 12:30 PM |');
      buffer.writeln('| **29-09-2026** | મંગળવાર | AI Product Design (AIPD) | DI05016021 | 11:30 AM – 12:30 PM |');
      buffer.writeln('| **30-09-2026** | બુધવાર | Cloud and Data Center Technology (CDCT) | DI05016031 | 11:30 AM – 12:30 PM |');
      buffer.writeln('| **01-10-2026** | ગુરુવાર | Foundation of Blockchain (FBC) | DI05016051 | 11:30 AM – 12:30 PM |');
      buffer.writeln('| **03-10-2026** | શનિવાર | **પરીક્ષા નથી (No Exam)** | — | — |\n');
      buffer.writeln('📌 **પરીક્ષા નિયમો & સૂચનાઓ:**');
      buffer.writeln('1. પરીક્ષા શરૂ થવાના **15 મિનિટ પહેલાં** (11:15 AM સુધીમાં) પરીક્ષા ખંડમાં પહોંચવું.');
      buffer.writeln('2. હોલ ટિકિટ (Hall Ticket) અને કોલેજ આઈ-કાર્ડ સાથે રાખવું ફરજિયાત છે.');
      buffer.writeln('3. પરીક્ષા ખંડમાં મોબાઈલ ફોન કે સ્માર્ટવોચ લઈ જવાની સખત મનાઈ છે.');
    } else {
      buffer.writeln('📅 **IT (Information Technology) — Semester 5 Mid-Sem Examination Schedule (Winter 2026)**\n');
      buffer.writeln('⏰ **Exam Timing: 11:30 AM – 12:30 PM**');
      buffer.writeln('🏫 **College:** Government Polytechnic Himmatnagar (GPH)\n');
      buffer.writeln('| Date | Day | Subject | Subject Code | Timing |');
      buffer.writeln('| :--- | :--- | :--- | :--- | :--- |');
      buffer.writeln('| **28-09-2026** | Monday | Artificial Intelligence with Prompt Engineering (AIPE) | DI05016011 | 11:30 AM – 12:30 PM |');
      buffer.writeln('| **29-09-2026** | Tuesday | AI Product Design (AIPD) | DI05016021 | 11:30 AM – 12:30 PM |');
      buffer.writeln('| **30-09-2026** | Wednesday | Cloud and Data Center Technology (CDCT) | DI05016031 | 11:30 AM – 12:30 PM |');
      buffer.writeln('| **01-10-2026** | Thursday | Foundation of Blockchain (FBC) | DI05016051 | 11:30 AM – 12:30 PM |');
      buffer.writeln('| **03-10-2026** | Saturday | **No Exam** | — | — |\n');
      buffer.writeln('📌 **Official Examination Instructions:**');
      buffer.writeln('1. Students must reach the examination hall at least **15 minutes before** (by 11:15 AM).');
      buffer.writeln('2. Bring your official **Hall Ticket** and **College ID Card**.');
      buffer.writeln('3. Mobile phones, smartwatches, and programmable calculators are strictly prohibited in the examination hall.');
    }

    return buffer.toString().trim();
  }
}
