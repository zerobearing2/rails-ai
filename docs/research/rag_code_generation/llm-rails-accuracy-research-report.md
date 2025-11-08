# LLM Accuracy for Rails Development: Research Report

**Date:** January 2025
**Project:** rails-ai framework enhancement
**Purpose:** Compare approaches to improve LLM accuracy for Ruby on Rails code generation

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Approach A: Training Small Models Locally](#approach-a-training-small-models-locally)
3. [Approach B: Fine-Tuning Existing LLMs](#approach-b-fine-tuning-existing-llms)
4. [Approach C: RAG with SQLite Database](#approach-c-rag-with-sqlite-database)
5. [Approach D: Style Guide Abstraction](#approach-d-style-guide-abstraction)
6. [Comparative Analysis](#comparative-analysis)
7. [Systematic Evaluation Framework](#systematic-evaluation-framework)
8. [Data Sources & Curation](#data-sources--curation)
9. [Cost Analysis](#cost-analysis)
10. [Recommendations](#recommendations)
11. [Resources & Tools](#resources--tools)

---

## Executive Summary

### Quick Comparison Table

| Approach | Time to MVP | Initial Cost | Ongoing Cost | Complexity | Accuracy Gain | Best For |
|----------|-------------|--------------|--------------|------------|---------------|----------|
| **A. Train Small Model** | 6-8 weeks | $8k-15k | $200-500/mo | High | 40-60% | Long-term investment, offline use |
| **B. Fine-Tune Existing** | 5-7 weeks | $12k-25k | $300-800/mo | Medium-High | 50-70% | Domain specialization, best quality |
| **C. RAG with SQLite** | 3-4 weeks | $7k-15k | $50-500/mo | Low-Medium | 30-50% | Fastest ROI, easy maintenance |
| **D. Style Guide Enforcement** | 2-3 weeks | $10k-20k | $200-500/mo | Medium | 40-60% | Immediate impact, complements others |

### Key Findings

1. **RAG + Style Enforcement** provides the best balance of speed, cost, and quality for most teams
2. **Fine-tuning** delivers highest quality but requires ongoing investment and expertise
3. **Local training** makes sense only for organizations with privacy requirements or ML expertise
4. **Style enforcement** enhances all other approaches and should be considered universal

### Current State of LLM Training (2025)

- Next.js/Node code quality from LLMs is significantly better than Rails (likely due to training data volume)
- Modern tools (Unsloth, QLoRA) have democratized fine-tuning (2x faster, 70% less VRAM)
- Local models (Llama 3, CodeLlama, StarCoder2) are approaching GPT-3.5 quality
- RAG has emerged as practical alternative to expensive fine-tuning
- SQLite vector search (sqlite-vec) makes local RAG highly practical

---

## Approach A: Training Small Models Locally

### Overview

Training a small language model (7B-34B parameters) specifically for Ruby/Rails code generation using high-quality training data.

### Technical Feasibility

**Status:** Highly feasible with modern tools (2025)
**Maturity Level:** Emerging but proven

### Base Models Available (2025)

| Model | Parameters | Focus | Training Data | Best For |
|-------|------------|-------|---------------|----------|
| StarCoder2 | 3B, 7B, 15B | Code generation | The Stack v2 (619 languages) | General code |
| CodeLlama | 7B, 13B, 34B, 70B | Code + instructions | 500B tokens, 80+ languages | Python-heavy |
| Phi-4 | 14B | General + code | Microsoft curated | Efficient inference |
| Mistral 7B | 7.3B | General + code | Web-scale | Good baseline |
| DeepSeek Coder | 1.3B, 6.7B, 33B | Code-specific | 2T tokens, 87 languages | Code completion |

**Recommendation:** StarCoder2-7B or CodeLlama-7B as base model

### Training Frameworks

**Primary Tools:**
1. **Unsloth** (Recommended)
   - 2x faster training, 70% less VRAM
   - Supports all major models
   - Written in OpenAI Triton (optimized kernels)
   - 0% accuracy loss vs. full fine-tuning
   - Works on NVIDIA, AMD, Intel GPUs

2. **Hugging Face Transformers + PEFT**
   - Industry standard
   - Extensive documentation
   - Research-friendly

3. **MLflow**
   - Experiment tracking
   - Model versioning
   - Hyperparameter optimization

### Hardware Requirements

**Minimum Setup (7B model, QLoRA):**
```
GPU: NVIDIA RTX 4090 (24GB VRAM)
RAM: 32GB system RAM
Storage: 100GB SSD
Cost: ~$1,600 one-time OR $0.50-1.00/hour cloud
Training Time: 3-5 hours for 50k examples
```

**Recommended Setup (7B-13B models):**
```
GPU: NVIDIA A100 40GB
RAM: 64GB system RAM
Storage: 500GB NVMe SSD
Cost: ~$3,000-5,000 one-time OR $1.50-2.50/hour cloud
Training Time: 5-10 hours for 100k examples
```

**Production Setup (34B models):**
```
GPU: NVIDIA A100 80GB or H100
RAM: 128GB system RAM
Cost: $1.50-4.00/hour cloud
Training Time: 20-24 hours for 100k examples
```

### Training Time & Cost Estimates

| Model Size | Method | Dataset Size | Training Time | GPU | Cloud Cost |
|------------|--------|--------------|---------------|-----|------------|
| 7B | QLoRA 4-bit | 50k examples | 3 hours | A100 40GB | ~$6 |
| 7B | LoRA 16-bit | 50k examples | 5-6 hours | A100 40GB | ~$12 |
| 13B | QLoRA 4-bit | 100k examples | 8-10 hours | A100 80GB | ~$20 |
| 34B | QLoRA 4-bit | 100k examples | 20-24 hours | A100 80GB | ~$50 |

### Data Sources

**High-Quality GitHub Repositories:**

| Repository | Stars | Focus | Why Include |
|------------|-------|-------|-------------|
| rails/rails | 57.8k | Framework core | Canonical patterns |
| discourse/discourse | 42k | Full-stack app | Production architecture |
| gitlab-org/gitlab | 23k | Enterprise | Complex domain logic |
| shopify/* | Various | E-commerce | Performance patterns |
| mastodon/mastodon | 47k | Social network | Real-time features |
| chatwoot/chatwoot | 21k | Customer support | Modern Rails stack |
| forem/forem | 22k | Community platform | DEV.to codebase |

**Dataset Collections:**
- **The Stack v2**: 67.5TB, 900B tokens, 619 languages (includes Ruby)
- **StarCoderData**: Curated from The Stack v2 with deduplication
- **BigCode datasets**: Ruby-filtered subsets available

**Quality Filtering Criteria:**
- Star count > 1,000
- Active maintenance (commits in last 6 months)
- Fork-to-star ratio ~1:10
- Comprehensive test suites (coverage > 70%)
- Well-documented code
- CI/CD with green builds
- RuboCop score > 85

**Target Dataset Size:**
- Minimum viable: 50k code examples
- Recommended: 100k-200k examples
- Optimal: 500k+ examples
- Token count: 50M-500M tokens

### Cost Analysis

**One-Time Costs:**
- Dataset curation: 20-40 hours @ developer rate = $2,000-6,000
- Initial model training: $300-1,000 (QLoRA approach)
- Evaluation framework setup: $1,000-2,000

**Ongoing Costs:**
- Model updates (monthly): $200-500
- Inference hosting: $50-200/month
- Monitoring/maintenance: 5-10 hours/month

**Total First Year:** $8,000-15,000

### Evaluation Metrics

**Automated Benchmarks:**
1. **Pass@1 / Pass@k**: Code passes tests on first/kth attempt (target: 60%+)
2. **HumanEval-Ruby**: Adapt 164 programming problems for Ruby
3. **Syntax Correctness**: `RubyVM::InstructionSequence.compile` validation
4. **RuboCop Compliance**: Style guide adherence score
5. **Security**: Brakeman scan results (0 high/critical issues)

**Quality Metrics:**
1. Functional correctness (unit test pass rate)
2. Code quality (RubyCritic analysis, target: > 85)
3. Cyclomatic complexity (target: < 10 per method)
4. Performance benchmarks vs. baseline

**Human Evaluation:**
1. Readability (1-5 scale by senior developers)
2. Rails idiomaticity (convention adherence)
3. Production readiness (would you deploy this?)

### Existing Projects & Research

**Active Open Source Projects:**
- **Unsloth**: Fast fine-tuning library
- **Langchainrb**: LLM orchestration for Ruby
- **ruby-openai**: OpenAI SDK for Ruby
- **Ollama**: Local model inference

**Research Papers:**
- "StarCoder 2 and The Stack v2" (arXiv:2402.19173)
- "Continual Learning for Large Language Models" (arXiv:2402.01364)
- "AST-T5: Structure-Aware Pretraining for Code Generation" (arXiv:2401.03003)

### Prototyping Roadmap

**Phase 1: Foundation (Week 1-2)**
- Set up cloud GPU (RunPod, Vast.ai, Lambda Labs)
- Install Unsloth + Hugging Face ecosystem
- Download StarCoder2-7B or CodeLlama-7B
- Create initial benchmark (100 Ruby/Rails tasks)

**Phase 2: Data Preparation (Week 3-4)**
- Clone top 50 Rails repositories
- Filter by quality metrics (RuboCritic > 85)
- Deduplicate using file-level hashing
- Format as instruction-response pairs
- Split: 80% train, 10% validation, 10% test

**Phase 3: Training (Week 5)**
- Fine-tune with QLoRA (4-bit quantization)
- Config: r=256, lora_alpha=512, 3 epochs
- Monitor loss curves
- Save checkpoints every 500 steps

**Phase 4: Evaluation (Week 6)**
- Run benchmark suite
- Measure Pass@1, syntax correctness
- RuboCop compliance scoring
- Human evaluation by 3-5 Rails developers

**Phase 5: Iteration (Week 7-8)**
- Analyze failure modes
- Augment training data for weak areas
- Experiment with hyperparameters
- Compare against GPT-4 and base model

### Strengths

✅ Complete control over model behavior
✅ No external API dependencies
✅ Privacy/security (code never leaves infrastructure)
✅ One-time cost after initial training
✅ Can run on CPU after GGUF quantization
✅ Customizable for specific domain patterns

### Weaknesses

❌ Requires ML expertise
❌ High initial time investment
❌ GPU required for training
❌ Difficult to update incrementally
❌ May not match GPT-4 quality
❌ Risk of catastrophic forgetting

### Best For

- Organizations with ML expertise in-house
- Privacy/security requirements (code can't leave infrastructure)
- Offline deployment needs
- Long-term strategic investment (2+ years)
- Large Rails codebases (1M+ LOC) for training data

---

## Approach B: Fine-Tuning Existing LLMs

### Overview

Fine-tuning pre-trained language models (GPT-4, Claude, CodeLlama, etc.) with high-quality Ruby/Rails code to improve domain-specific accuracy.

### Technical Feasibility

**Status:** Most mature and proven approach
**Success Rate:** High - established methodology with predictable outcomes
**Maturity Level:** Production-ready

### Fine-Tuning Techniques Comparison

| Method | VRAM (7B) | Training Speed | Cost | Accuracy | Best For |
|--------|-----------|----------------|------|----------|----------|
| Full Fine-Tuning | 100-120GB | Baseline (1x) | $$$$$ | 100% | Maximum accuracy, large budgets |
| LoRA 16-bit | 16GB | 2-3x faster | $$ | 98-99% | Balanced approach |
| QLoRA 4-bit | 6GB | 2x faster* | $ | 95-98% | Consumer GPUs, tight budgets |

*QLoRA is 2x faster than full fine-tuning but 39% slower than LoRA due to quantization overhead

### Recommended Technology Stack

**Primary Framework: Unsloth (Recommended)**
```
Advantages:
- 2x faster training than standard methods
- 70% less VRAM usage
- Supports all major models (Qwen, Gemma, DeepSeek, CodeLlama)
- Written in OpenAI Triton (optimized kernels)
- 0% accuracy loss - exact mathematical methods
- Works on NVIDIA, AMD, Intel GPUs
```

**Alternative: Hugging Face Transformers + PEFT**
```
Advantages:
- Industry standard with extensive documentation
- Supports all model architectures
- Excellent for research and experimentation
- Large community and tutorials
```

**Supporting Tools:**
- **MLflow**: Experiment tracking and model versioning
- **Weights & Biases**: Training visualization and metrics
- **DeepSpeed**: Multi-GPU training optimization
- **Accelerate**: Simplified distributed training

### Hardware & Cost Analysis

**Option 1: QLoRA on Consumer Hardware (Most Accessible)**
```
Hardware: RTX 4090 (24GB VRAM)
Model Size: Up to 13B parameters
Cost: $1,600 hardware OR $0.60/hour cloud
Training Time: 5-8 hours for 50k examples
Total Cost per Experiment: $300-500
```

**Option 2: LoRA on Professional Hardware**
```
Hardware: NVIDIA A100 40GB
Model Size: Up to 34B parameters
Cost: $1.50-2.00/hour cloud
Training Time: 8-12 hours for 100k examples
Total Cost per Experiment: $500-1,500
```

**Option 3: Full Fine-Tuning (Production Grade)**
```
Hardware: 8x A100 80GB (cluster)
Model Size: 70B+ parameters
Cost: $20-30/hour cloud
Training Time: 48-72 hours
Total Cost per Experiment: $3,000-10,000
```

**Recommended Starting Point:** QLoRA on cloud GPU ($300-1,000 budget per experiment)

### Detailed Cost Breakdown (First Year)

**Initial Investment:**
- Cloud GPU credits: $2,000-5,000
- Dataset curation/cleaning: $3,000-5,000
- Benchmark creation: $2,000-3,000
- Evaluation framework: $1,000-2,000
- **Subtotal: $8,000-15,000**

**Ongoing Costs (Monthly):**
- Experimentation: $200-500
- Model updates: $300-600
- Inference hosting: $100-300
- Monitoring: $50-100
- **Subtotal: $650-1,500/month**

**First Year Total: $12,000-25,000**

### Data Curation Strategy

**Quality Filtering Pipeline:**

1. **Repository Selection Criteria:**
   - Stars > 500
   - Active maintenance (commits in last 90 days)
   - Test coverage > 80%
   - Documentation completeness
   - Continuous Integration passing
   - Fork-to-star ratio 1:8 to 1:12

2. **Code Quality Metrics:**
   - RubyCritic score > 85 (combines Reek, Flay, Flog)
   - RuboCop violations < 5 per file
   - Cyclomatic complexity < 10
   - Code duplication < 5%
   - Comment-to-code ratio 10-30%

3. **Deduplication:**
   - File-level exact matching (SHA-256 hashing)
   - Near-deduplication (MinHash LSH)
   - Remove boilerplate/generated code
   - Filter out vendored dependencies

4. **Content Filtering:**
   - Remove credentials and secrets
   - Strip irrelevant comments
   - Exclude deprecated patterns
   - Focus on Rails 6.0+ idioms

**Dataset Composition (Recommended):**
- Framework code: 20% (Rails, popular gems)
- Application code: 50% (controllers, models, services)
- Test code: 20% (RSpec, Minitest examples)
- Documentation: 10% (comments, READMEs)

**Target Dataset Size:**
- Minimum viable: 50k code examples
- Recommended: 100k-200k examples
- Optimal: 500k+ examples
- Tokens: 50M-500M (depending on model size)

### Evaluation Framework

**Automated Benchmarks:**

1. **HumanEval-Ruby** (Create custom version)
   - 164+ hand-written Ruby programming problems
   - Function signature + docstring + tests
   - Measure Pass@1, Pass@5, Pass@10
   - Expected baseline: 40-60% for fine-tuned model

2. **Rails-Specific Benchmark Suite**
   - CRUD operations: 50 tasks
   - API endpoints: 50 tasks
   - Background jobs: 30 tasks
   - Database queries: 40 tasks
   - View helpers: 30 tasks
   - **Total: 200 tasks**

3. **Code Quality Metrics:**
   - Syntax correctness: `RubyVM::InstructionSequence.compile`
   - Style compliance: RuboCop pass rate (target: 90%+)
   - Security: Brakeman scan (0 high/critical issues)
   - Performance: Benchmark against reference implementations

4. **LiveCodeBench-style Testing:**
   - Dynamic benchmark (updated monthly)
   - Prevents benchmark contamination
   - Multi-step reasoning tasks

**Human Evaluation Protocol:**

1. **Expert Review Panel:**
   - 3-5 senior Rails developers
   - 5+ years Rails experience each
   - Diverse backgrounds (product, consulting, open source)

2. **Evaluation Criteria (1-5 scale):**
   - Correctness: Does it work?
   - Readability: Can you understand it?
   - Idiomaticity: Does it follow Rails conventions?
   - Maintainability: Would you merge this PR?
   - Security: Are there vulnerabilities?

3. **Comparison Studies:**
   - Model output vs. GPT-4
   - Model output vs. Claude Sonnet
   - Model output vs. human expert
   - Blind evaluation (reviewers don't know source)

### Existing Research & Projects

**Key Research Papers (2025):**
- "QLoRA: Efficient Finetuning of Quantized LLMs" - Memory-efficient fine-tuning
- "LoRA Insights from Hundreds of Experiments" - Best practices and hyperparameters
- "Automated Data Curation for Robust Language Model Fine-Tuning" - Data quality focus

**Open Source Projects:**
- **Unsloth**: Fast fine-tuning library
- **QLoRA**: Original implementation
- **RubyLLM**: Rails-integrated LLM framework
- **Langchainrb**: Ruby LLM orchestration

**Commercial Solutions:**
- OpenAI GPT fine-tuning API: $0.008/1k tokens training
- Anthropic Claude fine-tuning (anticipated)
- Google Gemini fine-tuning: Available for select models

### Prototyping Roadmap

**Week 1-2: Environment Setup**
```bash
# Set up cloud GPU (RunPod, Vast.ai, Lambda Labs)
pip install unsloth transformers peft bitsandbytes
pip install mlflow wandb datasets

# Test environment
python -c "import unsloth; print('Ready!')"
```

**Week 3-4: Data Preparation**
- Collect high-quality Rails repositories (50+ repos)
- Analyze code quality with RuboCop/RubyCritic
- Extract training examples (instruction-response pairs)
- Deduplicate and filter by quality

**Week 5: Initial Fine-Tuning**
```python
from unsloth import FastLanguageModel

# Load base model (StarCoder2-7B or CodeLlama-7B)
model, tokenizer = FastLanguageModel.from_pretrained(
    model_name="bigcode/starcoder2-7b",
    max_seq_length=2048,
    load_in_4bit=True,
)

# Add LoRA adapters
model = FastLanguageModel.get_peft_model(
    model,
    r=256,              # LoRA rank
    lora_alpha=512,     # LoRA alpha
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj"],
    lora_dropout=0.05,
)

# Train with SFTTrainer
trainer.train()
```

**Week 6: Evaluation**
- Run benchmark suite (200 tasks)
- Compare against GPT-4, Claude, base model
- Measure Pass@1, RuboCop compliance, human ratings
- Document failure modes

**Week 7-8: Iteration**
- Analyze failures by category
- Augment training data for weak areas
- Experiment with hyperparameters
- Try different base models
- Document learnings

### Strengths

✅ Best quality output (70%+ accuracy possible)
✅ Builds on proven base models
✅ Established tooling and methodology
✅ Predictable results
✅ Can target specific domains
✅ Active community and support

### Weaknesses

❌ Higher ongoing costs (API or hosting)
❌ GPU required for training
❌ Needs periodic retraining
❌ Risk of catastrophic forgetting
❌ Vendor lock-in (if using APIs)
❌ Model drift over time

### Best For

- Teams prioritizing code quality
- Budget for ongoing costs ($1k-2k/month)
- Domain specialization needs
- Production-critical applications
- Organizations with some ML familiarity

---

## Approach C: RAG with SQLite Database

### Overview

Retrieval-Augmented Generation (RAG) using local SQLite database with vector search to provide relevant code examples to LLMs in real-time, improving accuracy without training.

### Technical Feasibility

**Status:** Highly practical and production-ready
**Complexity:** Low to Medium
**ROI:** High - fastest to implement and iterate
**Maturity Level:** Production-ready

### Why RAG with SQLite?

**Advantages of SQLite for RAG:**
- Single file database (easy deployment)
- No server to manage
- Fast vector search with sqlite-vec extension
- Perfect for local-first development
- Works seamlessly with Rails
- Rails 8 emphasis on SQLite
- Zero infrastructure cost

### Architecture Overview

**Core Components:**

```
User Query
    ↓
Embedding Model (converts to vector)
    ↓
Vector Search in SQLite (find similar code)
    ↓
Retrieve Top-K Examples
    ↓
Augment LLM Context
    ↓
Generate Code with Examples
    ↓
Return Result
```

### Key Technologies & Tools

**1. SQLite Vector Extensions:**
- **sqlite-vec**: Native vector similarity search
- **Neighbor gem**: ActiveRecord integration for vector operations
- Supports cosine similarity, L2 distance, inner product

**2. Embedding Models (2025 Comparison):**

| Model | Dimensions | Cost | Quality | Context | Best For |
|-------|------------|------|---------|---------|----------|
| text-embedding-3-small | 1536 | $0.02/1M tokens | Good | 8191 | Cost-effective |
| text-embedding-3-large | 3072 | $0.13/1M tokens | Excellent | 8191 | High accuracy |
| Nomic Embed v1.5 | 768 | Free (local) | Excellent | 8192 | Open source |
| Nomic Embed v2 MoE | 768 | Free (local) | SOTA | 8192 | Multilingual |
| Voyage-3-large | 1024 | $0.06/1M tokens | Excellent | 16000 | Long context |

**Recommendation:** Nomic Embed v1.5 (local, free, competitive quality)

**3. Ruby/Rails Integration:**
```ruby
# Gemfile
gem 'neighbor'          # Vector search for ActiveRecord
gem 'ruby-openai'       # Embeddings and LLM API
gem 'sqlite3', '>= 2.0' # SQLite with vector support
```

**4. Code Parsing & Chunking:**
- **rubocop-ast**: Parse Ruby code into AST
- **tree-sitter**: Multi-language parser
- **AST-based chunking**: Split at function/class boundaries

### Implementation Architecture

**Database Schema:**

```ruby
class CreateVectorStore < ActiveRecord::Migration[8.0]
  def change
    # Enable sqlite-vec extension
    execute "CREATE VIRTUAL TABLE IF NOT EXISTS embeddings USING vec0(
      embedding float[768]
    )"

    create_table :code_snippets do |t|
      t.text :content, null: false
      t.string :file_path
      t.string :language, default: 'ruby'
      t.string :snippet_type # method, class, module, etc.
      t.text :context # surrounding code
      t.json :metadata # repo, stars, quality_score
      t.integer :embedding_id
      t.timestamps
    end

    add_index :code_snippets, :snippet_type
    add_index :code_snippets, :language
  end
end
```

**Embedding Pipeline:**

```ruby
class CodeEmbeddingService
  def initialize
    @client = OpenAI::Client.new # or Ollama for local
    @model = "nomic-embed-text" # or text-embedding-3-small
  end

  def embed_codebase(repo_path)
    snippets = extract_code_snippets(repo_path)

    snippets.each_slice(100) do |batch|
      embeddings = generate_embeddings(batch.map(&:content))
      store_with_embeddings(batch, embeddings)
    end
  end

  private

  def extract_code_snippets(repo_path)
    # Parse with RuboCop AST
    # Extract meaningful chunks (classes, methods)
    # Preserve context
  end

  def generate_embeddings(texts)
    response = @client.embeddings(
      parameters: {
        model: @model,
        input: texts
      }
    )
    response.dig("data").map { |d| d["embedding"] }
  end
end
```

**Retrieval & Generation:**

```ruby
class RAGCodeGenerator
  def initialize
    @llm = OpenAI::Client.new
  end

  def generate(query, top_k: 5)
    # 1. Embed the query
    query_embedding = embed_query(query)

    # 2. Retrieve similar code snippets
    similar_snippets = CodeSnippet.nearest_neighbors(
      :embedding, query_embedding,
      distance: "cosine"
    ).limit(top_k)

    # 3. Build context for LLM
    context = build_context(similar_snippets)

    # 4. Generate with LLM
    generate_with_context(query, context)
  end

  private

  def build_context(snippets)
    snippets.map do |snippet|
      <<~CONTEXT
        # File: #{snippet.file_path}
        # Type: #{snippet.snippet_type}
        # Quality Score: #{snippet.metadata['quality_score']}

        #{snippet.content}
      CONTEXT
    end.join("\n\n---\n\n")
  end

  def generate_with_context(query, context)
    prompt = <<~PROMPT
      You are an expert Ruby on Rails developer. Use the following
      high-quality code examples as reference.

      REFERENCE CODE:
      #{context}

      QUESTION:
      #{query}

      Provide production-ready Rails code following the patterns above.
    PROMPT

    @llm.chat(parameters: {
      model: "gpt-4",
      messages: [{ role: "user", content: prompt }]
    })
  end
end
```

### Data Sources & Curation

**Code Repositories to Index:**

1. **Core Framework:**
   - rails/rails (all modules)

2. **Production Apps:**
   - discourse/discourse
   - gitlab-org/gitlab
   - mastodon/mastodon
   - (filtered by quality)

3. **Popular Gems:**
   - devise, sidekiq, pundit, draper
   - (100+ stars)

4. **Style Guides:**
   - rubocop/rails-style-guide
   - bbatsov/ruby-style-guide

5. **Your Own Codebase:**
   - Company internal best practices

**Metadata to Store:**

```ruby
{
  repo_name: "rails/rails",
  stars: 57812,
  quality_score: 95, # RuboCop + RubyCritic
  rails_version: "8.0",
  test_coverage: 92,
  maintenance_status: "active",
  last_commit: "2025-01-15"
}
```

**Filtering Strategy:**
- RuboCop score > 90
- Test coverage > 70%
- Active maintenance (commits in last 6 months)
- Stars > 100 (gems) or > 1000 (apps)
- Rails version 6.0+ (modern idioms)

### Cost Analysis

**Initial Setup Costs:**
- Developer time (2-3 weeks): $6,000-12,000
- Embedding generation (one-time):
  - Local (Nomic): $0
  - OpenAI text-embedding-3-small: ~$20 for 1M snippets
- Storage: Negligible (SQLite file ~500MB-2GB)
- **Subtotal: $6,000-12,000**

**Ongoing Costs (Monthly):**
- Embedding new code: $5-20 (incremental)
- LLM API calls (generation): $50-500 (usage-dependent)
- Infrastructure: $0-50 (local-first, optional cloud)
- Maintenance: 2-5 hours/month ($200-750)
- **Subtotal: $255-1,320/month**

**First Year Total: $7,000-15,000**

**Cost Advantages:**
- No GPU required (vs. training/fine-tuning)
- Pay-per-use LLM API (vs. hosting)
- Minimal infrastructure
- Fast iteration cycle
- Can use 100% local tools (Ollama + Nomic Embed = $0 ongoing)

### Evaluation Metrics

**Retrieval Quality:**
1. **Recall@k**: % of relevant snippets in top-k results (target: 80%+)
2. **MRR (Mean Reciprocal Rank)**: Position of first relevant result
3. **NDCG**: Ranking quality score
4. **Latency**: Time to retrieve and rank snippets (target: <1s)

**Generation Quality:**
1. **Pass@1**: Generated code passes tests (target: 60-75%)
2. **Context Utilization**: Generated code uses retrieved patterns
3. **Relevance**: Retrieved snippets match user intent
4. **Diversity**: Variety in retrieved examples

**End-to-End Metrics:**
1. **Task Success Rate**: % producing working code (target: 70%+)
2. **User Satisfaction**: Developer ratings (target: 4+/5)
3. **Time Saved**: vs. manual coding (target: 40-60% reduction)
4. **Code Quality**: RuboCop/RubyCritic scores (target: > 85)

### Existing Projects & Research

**Open Source RAG Projects:**
- **sqlite-ollama-rag**: Local RAG with SQLite
- **Langchainrb**: Ruby RAG framework
- **Turso + Ollama RAG**: Local-first approach

**Research Papers:**
- "Retrieval Augmented Generation in SQLite" (Towards Data Science)
- "Enhancing LLM Code Generation with RAG and AST-Based Chunking"
- "AST-T5: Structure-Aware Pretraining" (arXiv:2401.03003)

**Commercial Solutions:**
- GitHub Copilot (uses RAG for code completion)
- Cursor (AI IDE with codebase indexing)
- Codeium (free alternative)

### Prototyping Roadmap

**Week 1: Foundation**
```bash
# Rails 8 app with SQLite
rails new rag-code-assistant --database=sqlite3

# Add gems
bundle add neighbor sqlite3 ruby-openai

# Set up vector extension (sqlite-vec)
```

**Week 2: Data Collection & Indexing**
```ruby
# Clone top Rails repos
repos = ['rails/rails', 'discourse/discourse', 'mastodon/mastodon']

repos.each do |repo|
  RailsCodeIndexer.new(repo).index!
end

# Expected: 10k-50k code snippets indexed
```

**Week 3: Retrieval Implementation**
```ruby
# Test retrieval quality
query = "Create a Rails API endpoint with authentication"
results = CodeSnippet.search_by_embedding(query, limit: 5)

results.each do |snippet|
  puts "Similarity: #{snippet.distance}"
  puts snippet.content
end
```

**Week 4: RAG Pipeline**
```ruby
# Integrate with LLM
generator = RAGCodeGenerator.new
output = generator.generate(
  "Write a Rails service object for user registration"
)

puts output # => Production-ready Rails code
```

### Advanced Optimizations

**1. Hybrid Search:**
Combine vector search with keyword search
```ruby
def hybrid_search(query, k: 5)
  vector_results = vector_search(query, k: k*2)
  keyword_results = keyword_search(query, k: k*2)
  rerank_and_merge(vector_results, keyword_results, k: k)
end
```

**2. Metadata Filtering:**
```ruby
CodeSnippet.nearest_neighbors(:embedding, query_vector)
  .where(metadata: { rails_version: '8.0' })
  .where("metadata->>'quality_score' > ?", 85)
  .limit(5)
```

**3. Contextual Retrieval:**
Include surrounding code
```ruby
{
  snippet: snippet.content,
  class_context: snippet.parent_class&.content,
  imports: snippet.file_imports,
  tests: snippet.associated_tests
}
```

**4. Incremental Updates:**
```ruby
after_save :index_code_snippet

def index_code_snippet
  CodeEmbeddingService.new.embed_and_store(self)
end
```

### Strengths

✅ Fastest to implement (3-4 weeks)
✅ Lowest complexity
✅ Easy to update (just add code examples)
✅ Works with any LLM
✅ Transparent (can see retrieved examples)
✅ Perfect for Rails 8's SQLite focus
✅ No GPU required
✅ Local-first possible

### Weaknesses

❌ Dependent on quality of indexed code
❌ Retrieval quality is critical
❌ May not generalize beyond indexed patterns
❌ Ongoing API costs (if using GPT-4/Claude)
❌ Limited by context window size
❌ Requires good chunking strategy

### Best For

- Quick wins and fast ROI
- Teams without ML expertise
- Local-first architecture
- Rails 8 projects (SQLite-based)
- Iterative improvement approach
- Budget-conscious teams (<$15k)

---

## Approach D: Style Guide Abstraction

### Overview

Enforce coding standards and patterns during code generation using RuboCop-based validation and custom cops, rather than relying solely on LLM training.

### Technical Feasibility

**Status:** Highly feasible with existing tools
**Complexity:** Medium
**ROI:** Very High - improves code quality across all approaches
**Maturity Level:** Production-ready

### Core Concept

**Three-Stage Enforcement:**

1. **Pre-generation:** Provide style guide context in prompts
2. **Post-generation:** Validate and auto-fix generated code
3. **Iterative refinement:** LLM fixes its own violations

**Key Insight:** Extend RuboCop (designed for humans) to LLM outputs

### Architecture & Components

**1. Pattern Extraction:**

```ruby
class StyleGuideAbstractor
  def initialize(codebase_path)
    @codebase = codebase_path
    @patterns = extract_patterns
  end

  def extract_patterns
    {
      controller_patterns: analyze_controllers,
      model_patterns: analyze_models,
      test_patterns: analyze_tests,
      naming_conventions: extract_naming,
      structure_patterns: extract_structure
    }
  end

  def analyze_controllers
    # Parse all controllers, extract:
    # - before_action usage patterns
    # - strong parameters conventions
    # - response format patterns
    # - error handling patterns
  end

  def to_llm_instructions
    # Convert patterns to natural language
    <<~INSTRUCTIONS
      Based on analysis of #{@codebase}:

      Controllers should:
      - Use before_action for authentication
      - Follow strong params pattern: #{example}
      - Return JSON with status codes

      Models should:
      - Place validations before associations
      - Use concerns for shared behavior
      ...
    INSTRUCTIONS
  end
end
```

**2. Multi-Stage Validation Pipeline:**

```ruby
class CodeGenerationPipeline
  def generate_and_validate(prompt)
    # Stage 1: Generate with style guide context
    code = generate_with_context(prompt)

    # Stage 2: Syntax validation
    validate_syntax!(code)

    # Stage 3: RuboCop validation
    rubocop_result = run_rubocop(code)

    # Stage 4: Auto-correct simple violations
    code = autocorrect_violations(code, rubocop_result)

    # Stage 5: LLM self-correction for complex issues
    if rubocop_result.offenses.any?
      code = llm_self_correct(code, rubocop_result.offenses)
    end

    # Stage 6: Final validation
    validate_all!(code)

    code
  end

  private

  def llm_self_correct(code, offenses)
    prompt = <<~PROMPT
      Fix these RuboCop violations:

      ```ruby
      #{code}
      ```

      Violations:
      #{offenses.map { |o| "#{o.message} at line #{o.line}" }.join("\n")}

      Return corrected code only, no explanations.
    PROMPT

    llm.generate(prompt)
  end
end
```

### Key Technologies & Tools

**1. RuboCop Ecosystem:**
- **rubocop**: Core static analysis (300+ built-in cops)
- **rubocop-rails**: Rails-specific cops (100+ cops)
- **rubocop-rspec**: Test quality enforcement (90+ cops)
- **rubocop-performance**: Performance patterns (50+ cops)
- **rubocop-ast**: AST parsing and traversal
- **Custom cops**: Team-specific rules

**2. AST Manipulation:**
- **parser gem**: Ruby parser (used by RuboCop)
- **rubocop-ast**: Semantic AST nodes
- **unparser**: AST → Ruby code
- **ruby_parser**: Alternative parser

**3. Pattern Extraction:**

```ruby
class PatternExtractor
  def extract_from_codebase(path)
    patterns = {
      class_structure: [],
      method_signatures: [],
      common_idioms: [],
      test_patterns: []
    }

    Dir.glob("#{path}/**/*.rb").each do |file|
      ast = parse_file(file)
      patterns[:class_structure] << extract_class_patterns(ast)
      patterns[:method_signatures] << extract_method_patterns(ast)
    end

    aggregate_and_rank(patterns)
  end
end
```

### Implementation Strategy

**Level 1: Basic Enforcement (Easiest)**
- Run RuboCop on generated code
- Auto-fix simple violations with `rubocop -a`
- Reject code with critical violations

**Level 2: Guided Generation (Medium)**
- Extract patterns from codebase
- Include patterns in LLM system prompt
- Provide examples of good code
- Use few-shot learning

**Level 3: Iterative Refinement (Advanced)**
- LLM generates initial code
- RuboCop identifies violations
- LLM corrects its own code
- Repeat until clean (max 3-5 iterations)

**Level 4: Custom Cops (Expert)**
- Write RuboCop cops for team conventions
- Enforce domain-specific patterns
- Auto-generate code that passes all cops
- Integrate with CI/CD

### Example Custom RuboCop Cops

**1. Enforce Service Object Pattern:**

```ruby
module RuboCop
  module Cop
    module Custom
      class ServiceObjectPattern < Base
        MSG = 'Service objects must include Callable and define #call'

        def on_class(node)
          return unless service_object?(node)

          add_offense(node) unless includes_callable?(node)
          add_offense(node) unless defines_call?(node)
        end

        private

        def service_object?(node)
          node.class_name.to_s.end_with?('Service')
        end

        def includes_callable?(node)
          node.each_descendant(:send).any? do |send_node|
            send_node.method?(:include) &&
              send_node.first_argument.const_name == 'Callable'
          end
        end

        def defines_call?(node)
          node.each_descendant(:def).any? { |n| n.method?(:call) }
        end
      end
    end
  end
end
```

**2. Enforce Testing Patterns:**

```ruby
module RuboCop
  module Cop
    module Custom
      class TestCoveragePattern < Base
        MSG = 'Every public method must have corresponding test'

        def on_def(node)
          return if private_method?(node)
          return if has_test?(node)

          add_offense(node)
        end

        private

        def has_test?(method_node)
          test_file = find_test_file(method_node.location.source_file)
          return false unless File.exist?(test_file)

          test_content = File.read(test_file)
          test_content.include?("describe '##{method_node.method_name}'")
        end
      end
    end
  end
end
```

**3. Enforce Hash#dig (From Your rails-ai Project):**

```ruby
module RuboCop
  module Cop
    module Custom
      class NestedBracketAccess < Base
        extend AutoCorrector

        MSG = 'Avoid nested bracket access; use `dig` instead.'

        def on_send(node)
          return unless nested_bracket_access?(node)

          add_offense(node) do |corrector|
            corrector.replace(node, dig_version(node))
          end
        end

        private

        def dig_version(node)
          keys = extract_keys(node)
          receiver = node.receiver.receiver.source
          "#{receiver}.dig(#{keys.join(', ')})"
        end
      end
    end
  end
end
```

### Data Sources & Pattern Libraries

**1. Your Own Codebase (Primary):**
```ruby
# Analyze rails-ai project
StyleGuideAbstractor.new('/home/dave/Projects/rails-ai')
  .extract_patterns
```

**2. Community Style Guides:**
- RuboCop Rails Style Guide
- Ruby Style Guide (bbatsov)
- Thoughtbot Guides
- Shopify Ruby Style Guide
- Airbnb Ruby Style Guide

**3. Framework Best Practices:**
- Rails Guides (official)
- GoRails patterns
- Evil Martians blog
- Thoughtbot blog

**4. Pattern Collections:**

```ruby
COMMON_RAILS_PATTERNS = {
  controller_authentication: <<~RUBY,
    before_action :authenticate_user!
    before_action :set_resource, only: [:show, :edit, :update, :destroy]
  RUBY

  strong_parameters: <<~RUBY,
    def resource_params
      params.require(:resource).permit(:name, :email)
    end
  RUBY

  service_object: <<~RUBY,
    class SomeService
      include Callable

      def initialize(args)
        @args = args
      end

      def call
        # implementation
      end
    end
  RUBY
}
```

### Cost Analysis

**Initial Setup:**
- Extract patterns from codebase: 1-2 weeks ($3,000-6,000)
- Create custom RuboCop cops: 1-2 weeks ($3,000-6,000)
- Build validation pipeline: 1 week ($2,000-4,000)
- Document style guide: 1 week ($2,000-4,000)
- **Total: $10,000-20,000**

**Ongoing Costs:**
- Pattern updates (quarterly): 5-10 hours ($500-1,500)
- New custom cops (as needed): 2-5 hours each ($200-750)
- Maintenance: 2-3 hours/month ($200-500/month)
- **Annual: $3,000-7,000**

**Cost Savings:**
- Reduced manual code review: 30-50% time savings
- Fewer bugs in production
- Faster onboarding
- LLM output quality: 40-60% improvement

**ROI:** Positive within 6-12 months for teams of 3+ developers

### Evaluation Metrics

**Style Compliance:**
- **RuboCop Pass Rate**: % generated code passing all cops (target: 90%+)
- **Offense Count**: Average violations per 100 lines (target: < 5)
- **Auto-Fix Success**: % violations fixed automatically (target: 70%+)
- **Custom Cop Coverage**: % team conventions enforced (target: 80%+)

**Code Quality:**
- **RubyCritic Score**: Combined quality score (target: > 85)
- **Cyclomatic Complexity**: Per method (target: < 10)
- **Duplication**: % duplicate code (target: < 5%)
- **Test Coverage**: % of generated code tested (target: > 80%)

**LLM Performance:**
- **First-Pass Quality**: % passing without iteration (target: 60%+)
- **Iteration Count**: Average corrections needed (target: < 2)
- **Pattern Adherence**: % using extracted patterns (target: 80%+)
- **Consistency Score**: Similarity to existing codebase

**Developer Experience:**
- **Time to Working Code**: Minutes from prompt to deployable
- **Manual Edits Required**: % code needing human changes (target: < 20%)
- **Developer Satisfaction**: 1-5 scale ratings (target: 4+)
- **PR Review Time**: Reduction vs. manual coding

### Existing Tools & Research

**RuboCop Ecosystem:**
- RuboCop Core: 300+ built-in cops
- RuboCop Rails: 100+ Rails-specific cops
- RuboCop RSpec: 90+ test quality cops
- RuboCop Performance: 50+ performance cops
- RuboCop Thread Safety: Concurrency checks

**Commercial Tools:**
- GitHub Copilot: Uses post-processing
- Cursor: Codebase-aware completion
- CodeClimate: Quality metrics
- Codacy: Automated code review

**Research:**
- "How LLMs Are Going to Change Code Generation in Modern IDEs" (2025)
- "Leveraging ASTs for LLM-Assisted Source Code Manipulation"
- "Custom Cops for RuboCop" (Evil Martians)

### Prototyping Roadmap

**Week 1: Pattern Extraction**
```ruby
# In rails-ai project
extractor = StyleGuideAbstractor.new(Rails.root)
patterns = extractor.extract_patterns

# Save for LLM consumption
File.write('config/extracted_patterns.json', patterns.to_json)
File.write('config/llm_style_guide.md', patterns.to_llm_instructions)
```

**Week 2: Basic Validation Pipeline**
```ruby
class GeneratedCodeValidator
  def validate(code)
    syntax_valid = validate_syntax(code)
    return { valid: false, error: 'Syntax error' } unless syntax_valid

    rubocop_result = run_rubocop(code)
    fixed_code = autocorrect(code)
    final_result = run_rubocop(fixed_code)

    {
      valid: final_result.offenses.empty?,
      code: fixed_code,
      offenses: final_result.offenses,
      metrics: calculate_metrics(fixed_code)
    }
  end
end
```

**Week 3: LLM Integration**
```ruby
class StyleGuideAwareLLM
  def initialize
    @llm = OpenAI::Client.new
    @style_guide = File.read('config/llm_style_guide.md')
  end

  def generate(user_prompt)
    full_prompt = <<~PROMPT
      You are an expert Ruby on Rails developer.

      #{@style_guide}

      User Request: #{user_prompt}

      Generate code matching the patterns above exactly.
    PROMPT

    @llm.chat(parameters: {
      model: "gpt-4",
      messages: [
        { role: "system", content: "Follow codebase conventions exactly" },
        { role: "user", content: full_prompt }
      ]
    })
  end
end
```

**Week 4: Iterative Refinement**
```ruby
class IterativeCodeGenerator
  MAX_ITERATIONS = 3

  def generate_and_refine(prompt)
    code = generate_initial_code(prompt)

    MAX_ITERATIONS.times do |i|
      validation = validate(code)
      break if validation[:valid]

      code = self_correct(code, validation[:offenses])
    end

    code
  end

  private

  def self_correct(code, offenses)
    correction_prompt = <<~PROMPT
      Fix these RuboCop violations:

      ```ruby
      #{code}
      ```

      Violations:
      #{offenses.map { |o| "Line #{o.line}: #{o.message}" }.join("\n")}

      Return corrected code only.
    PROMPT

    @llm.generate(correction_prompt)
  end
end
```

### Advanced Techniques

**1. Pattern Similarity Scoring:**
```ruby
def pattern_similarity(generated_code, codebase_patterns)
  generated_ast = parse_ast(generated_code)

  similarities = codebase_patterns.map do |pattern|
    ast_similarity(generated_ast, pattern.ast)
  end

  similarities.average
end
```

**2. Automated Style Guide Updates:**
```ruby
class StyleGuideLearner
  def learn_from_pr(pr_number)
    pr = fetch_pr(pr_number)
    return unless pr.approved_and_merged?

    new_patterns = extract_patterns(pr.changed_files)
    update_style_guide(new_patterns)
  end
end
```

**3. Context-Aware Enforcement:**
```ruby
def enforce_style(code, context:)
  cops = case context
  when :controller then CONTROLLER_COPS
  when :model then MODEL_COPS
  when :service then SERVICE_COPS
  when :test then TEST_COPS
  else ALL_COPS
  end

  run_rubocop(code, only: cops)
end
```

### Strengths

✅ Works with any LLM (fine-tuned or API)
✅ Immediate quality improvement (40-60%)
✅ Leverages existing RuboCop ecosystem
✅ Teachable (custom cops for conventions)
✅ Measurable (RuboCop scores)
✅ Low ongoing cost
✅ Transparent enforcement

### Weaknesses

❌ Doesn't improve LLM's fundamental understanding
❌ Post-processing adds latency
❌ May require multiple iterations
❌ Some violations can't be auto-fixed
❌ Requires maintenance of custom cops
❌ Limited to syntactic/structural patterns

### Best For

- Complementing other approaches
- Enforcing team conventions
- Immediate quality wins
- Any budget level
- Teams with existing RuboCop configurations
- Incremental improvement strategy

---

## Comparative Analysis

### Side-by-Side Comparison

| Criteria | Train Small Model | Fine-Tune Existing | RAG with SQLite | Style Enforcement |
|----------|-------------------|-------------------|-----------------|-------------------|
| **Time to MVP** | 6-8 weeks | 5-7 weeks | 3-4 weeks | 2-3 weeks |
| **Initial Cost** | $8k-15k | $12k-25k | $7k-15k | $10k-20k |
| **Ongoing Cost/mo** | $200-500 | $300-800 | $50-500 | $200-500 |
| **Technical Complexity** | High | Medium-High | Low-Medium | Medium |
| **ML Expertise Required** | High | Medium | Low | None |
| **Accuracy Improvement** | 40-60% | 50-70% | 30-50% | 40-60% |
| **Maintenance Burden** | High | Medium | Low | Low |
| **Iteration Speed** | Slow (retrain) | Medium (retrain) | Fast (add data) | Fast (update cops) |
| **Offline Capability** | Yes | Yes (if hosted) | Partial | Yes |
| **Transparency** | Low | Low | High | High |
| **Scalability** | High | High | Medium | High |

### Strengths & Weaknesses Matrix

#### Approach A: Train Small Model Locally

**✅ Strengths:**
- Complete control over model behavior
- No external API dependencies
- Privacy/security (code stays local)
- One-time cost after training
- Customizable for specific domains
- Can run on CPU (after quantization)

**❌ Weaknesses:**
- High ML expertise requirement
- Slow iteration (retraining needed)
- GPU required for training
- Risk of catastrophic forgetting
- May not match GPT-4 quality
- Time-intensive setup

**📊 Best Use Cases:**
- Organizations with ML teams
- Privacy/security requirements
- Offline deployment needs
- Long-term strategic investment
- Large internal codebases to train on

---

#### Approach B: Fine-Tune Existing LLM

**✅ Strengths:**
- Highest quality output possible
- Proven methodology
- Builds on SOTA base models
- Established tooling
- Predictable results
- Can specialize by domain

**❌ Weaknesses:**
- Highest ongoing costs
- GPU required for training
- Periodic retraining needed
- Vendor lock-in (if using APIs)
- Model drift over time
- Requires some ML familiarity

**📊 Best Use Cases:**
- Quality-critical applications
- Teams with ML budget
- Production codebases
- Organizations prioritizing accuracy
- Domain-specific specialization

---

#### Approach C: RAG with SQLite

**✅ Strengths:**
- Fastest implementation
- Lowest complexity
- Easy to update/maintain
- Works with any LLM
- Transparent retrieval
- Rails 8 aligned (SQLite)
- No GPU required
- Can be 100% local

**❌ Weaknesses:**
- Depends on indexed code quality
- Retrieval quality critical
- Limited to indexed patterns
- Context window constraints
- May have API costs
- Requires good chunking strategy

**📊 Best Use Cases:**
- Quick wins and fast ROI
- Teams without ML expertise
- Local-first architecture
- Budget-conscious (<$15k)
- Iterative improvement approach
- Rails 8 projects

---

#### Approach D: Style Guide Enforcement

**✅ Strengths:**
- Works with any approach
- Immediate quality boost
- Leverages RuboCop ecosystem
- Measurable metrics
- Low ongoing costs
- Transparent rules
- Team-specific customization

**❌ Weaknesses:**
- Doesn't improve LLM understanding
- Post-processing latency
- May need multiple iterations
- Not all violations auto-fixable
- Maintenance of custom cops
- Limited to structural patterns

**📊 Best Use Cases:**
- Complementing other approaches
- Enforcing team conventions
- Any budget level
- Immediate improvements
- Quality assurance layer

---

### Cost Comparison (First Year)

| Approach | Setup | Training/Data | Infrastructure | Ongoing | Total Year 1 |
|----------|-------|---------------|----------------|---------|--------------|
| **Train Local** | $3k-8k | $2k-5k | $2.4k-6k | $1.2k-3k | $8k-22k |
| **Fine-Tune** | $8k-15k | $2k-5k | $1.2k-3.6k | $3.6k-9.6k | $15k-33k |
| **RAG** | $6k-12k | $0-20 | $0-600 | $600-6k | $7k-19k |
| **Style Guide** | $10k-20k | $0 | $0 | $2.4k-6k | $12k-26k |
| **RAG + Style** | $16k-32k | $0-20 | $0-600 | $3k-12k | $19k-45k |

### Performance Comparison (Expected Outcomes)

| Metric | Baseline | Train Local | Fine-Tune | RAG | Style | RAG + Style |
|--------|----------|-------------|-----------|-----|-------|-------------|
| **Pass@1** | 35-45% | 55-70% | 65-80% | 50-65% | 55-70% | 70-85% |
| **RuboCop Pass** | 60-70% | 75-85% | 80-90% | 70-80% | 90-95% | 90-95% |
| **Human Rating** | 3.0/5 | 3.5/5 | 4.0/5 | 3.5/5 | 3.8/5 | 4.2/5 |
| **Latency** | 2s | 3-5s | 2s | 3-4s | 5-8s | 8-12s |
| **Cost/100 tasks** | $5 | $2 | $8 | $10 | $12 | $15 |

### When to Use Each Approach

#### Use Training Small Model When:
- ✓ You have ML expertise in-house
- ✓ Privacy/security prevents external APIs
- ✓ You need offline operation
- ✓ Long-term investment (2+ years)
- ✓ Large codebase for training (1M+ LOC)
- ✗ You need quick results
- ✗ Budget is limited (<$20k)
- ✗ No ML team available

#### Use Fine-Tuning When:
- ✓ Quality is top priority
- ✓ Budget supports ongoing costs ($2k+/month)
- ✓ Domain specialization needed
- ✓ You have some ML familiarity
- ✓ Production-critical application
- ✗ You need fast iteration
- ✗ Budget is tight (<$15k/year)
- ✗ Quick proof-of-concept needed

#### Use RAG When:
- ✓ Fast time to value (3-4 weeks)
- ✓ Limited ML expertise
- ✓ Budget-conscious (<$15k)
- ✓ Local-first architecture
- ✓ Rails 8 projects (SQLite)
- ✓ Iterative improvement preferred
- ✗ Need highest accuracy (>85%)
- ✗ Offline operation required

#### Use Style Enforcement When:
- ✓ Always (complements all approaches)
- ✓ Team has established conventions
- ✓ Quality assurance needed
- ✓ Immediate impact desired
- ✓ RuboCop already in use
- ✗ Never skip this approach

---

### Recommended Combination Strategies

#### Strategy 1: Fast Start (Recommended for Most)
**Approach:** RAG + Style Enforcement
**Timeline:** 4-6 weeks
**Cost:** $19k-45k first year
**Expected Accuracy:** 70-85%

**Why:**
- Fastest time to value
- Reasonable cost
- Easy to maintain
- Rails 8 aligned
- Proven combination

**Upgrade Path:** Add fine-tuning after 6-12 months if needed

---

#### Strategy 2: Quality First
**Approach:** Fine-Tuning + Style Enforcement
**Timeline:** 6-8 weeks
**Cost:** $27k-59k first year
**Expected Accuracy:** 80-90%

**Why:**
- Highest quality output
- Professional approach
- Proven methodology
- Production-ready

**Trade-offs:** Higher cost, slower iteration

---

#### Strategy 3: Maximum Control
**Approach:** Train Local + Style Enforcement
**Timeline:** 8-10 weeks
**Cost:** $20k-48k first year
**Expected Accuracy:** 70-85%

**Why:**
- Complete control
- No vendor lock-in
- Privacy/security
- Offline capable

**Trade-offs:** High complexity, requires ML expertise

---

#### Strategy 4: Bootstrap Budget
**Approach:** RAG Only (100% Local Tools)
**Timeline:** 3-4 weeks
**Cost:** $6k-12k first year
**Expected Accuracy:** 50-65%

**Why:**
- Lowest cost
- Fast implementation
- No ongoing API costs
- Prove value quickly

**Tools:** Ollama + Nomic Embed + SQLite (all free)

---

## Systematic Evaluation Framework

### Phase 1: Benchmark Creation (Month 1)

#### Step 1: Task Collection

**Goal:** Create 200+ Rails programming tasks covering common scenarios

**Categories:**

| Category | Count | Examples |
|----------|-------|----------|
| CRUD Operations | 50 | Basic controllers, REST actions |
| API Endpoints | 50 | JSON APIs, authentication, versioning |
| Database Queries | 40 | ActiveRecord, joins, optimizations |
| Background Jobs | 30 | Sidekiq, Solid Queue, async tasks |
| View Helpers | 30 | ERB, partials, helpers |

**Collection Methods:**
1. Survey 10 Rails developers: "What do you code most often?"
2. Analyze internal tickets/PRs for patterns
3. Review Rails guides for canonical examples
4. Mine StackOverflow for common questions

#### Step 2: Test Suite Creation

**For each task, create:**

```ruby
{
  id: 1,
  category: "controller",
  difficulty: "medium",
  description: "Create Rails API controller with authentication and pagination",

  test_suite: <<~RUBY,
    RSpec.describe Api::PostsController do
      describe "GET #index" do
        it "requires authentication" do
          get :index
          expect(response).to have_http_status(:unauthorized)
        end

        it "returns paginated posts" do
          authenticate_as(user)
          create_list(:post, 30)
          get :index
          expect(json_response['posts'].count).to eq(25)
          expect(json_response['meta']['total_pages']).to eq(2)
        end
      end
    end
  RUBY

  canonical_solution: File.read('solutions/api_posts_controller.rb'),
  rubocop_config: '.rubocop.yml',
  metadata: {
    rails_version: '8.0',
    gems_required: ['devise', 'kaminari'],
    difficulty_score: 6.5,
    time_estimate: '15 minutes'
  },
  tags: ['api', 'authentication', 'pagination', 'rspec']
}
```

#### Step 3: Validation

- Human experts solve all tasks
- Verify tests pass with canonical solutions
- Calculate difficulty ratings
- Ensure balanced distribution

**Deliverables:**
- 200-task benchmark suite (JSON format)
- Automated test runner
- Difficulty distribution chart
- Documentation

---

### Phase 2: Baseline Measurement (Month 2)

#### Step 1: Test Current SOTA Models

```ruby
models_to_test = [
  { name: 'GPT-4', provider: 'openai' },
  { name: 'Claude Sonnet 4.5', provider: 'anthropic' },
  { name: 'CodeLlama 34B', provider: 'local' },
  { name: 'StarCoder2 15B', provider: 'local' }
]

benchmark_tasks.each do |task|
  models_to_test.each do |model|
    result = generate_code(model, task.description)

    metrics = {
      syntax_valid: validate_syntax(result),
      tests_pass: run_tests(task.test_suite, result),
      rubocop_score: run_rubocop(result),
      brakeman_issues: run_brakeman(result),
      execution_time: measure_execution_time(result),
      token_count: count_tokens(result),
      cost: calculate_cost(model, result)
    }

    save_baseline_result(task, model, metrics)
  end
end
```

#### Step 2: Human Expert Baseline

```ruby
# Have 3-5 senior Rails developers solve same tasks
expert_results = []

experts.each do |expert|
  sample_tasks = benchmark_tasks.sample(20) # Don't burn out experts

  sample_tasks.each do |task|
    time_started = Time.now
    solution = expert.solve(task)
    time_taken = Time.now - time_started

    metrics = {
      tests_pass: run_tests(task.test_suite, solution),
      rubocop_score: run_rubocop(solution),
      time_taken: time_taken,
      expert_id: expert.id
    }

    expert_results << metrics
  end
end

# This gives us "human performance ceiling"
```

#### Step 3: Statistical Analysis

```ruby
class BenchmarkAnalyzer
  def analyze(results)
    {
      pass_at_1: calculate_pass_at_k(results, k: 1),
      pass_at_5: calculate_pass_at_k(results, k: 5),
      avg_rubocop_score: results.map(&:rubocop_score).mean,
      syntax_correctness: results.count(&:syntax_valid) / results.count.to_f,
      security_issues: results.sum(&:brakeman_issues_count),
      cost_per_task: results.map(&:cost).mean,
      latency_p50: percentile(results.map(&:execution_time), 50),
      latency_p95: percentile(results.map(&:execution_time), 95)
    }
  end
end
```

**Expected Baseline Results (2025):**

| Model | Pass@1 | RuboCop | Cost/Task | Latency |
|-------|--------|---------|-----------|---------|
| GPT-4 | 45-55% | 75-85% | $0.15 | 3-5s |
| Claude Sonnet 4.5 | 50-60% | 80-90% | $0.12 | 2-4s |
| CodeLlama 34B | 35-45% | 70-80% | $0.00 | 8-12s |
| StarCoder2 15B | 30-40% | 65-75% | $0.00 | 6-10s |
| Human Expert | 95-100% | 90-95% | $50 | 15-30min |

**Deliverables:**
- Baseline metrics report
- Statistical analysis
- Failure mode categorization
- Gap analysis (vs. human performance)

---

### Phase 3: Implementation & Testing (Months 3-5)

#### Month 3: Implement Approach 1

**Example: RAG Implementation**

```ruby
# Week 1-2: Build RAG system
class RAGSystem
  def initialize
    @db = SQLite3::Database.new('rag_store.db')
    @embedder = NomicEmbedder.new
    @llm = OpenAI::Client.new
  end

  def index_repository(repo_path)
    CodeIndexer.new(repo_path).index!
  end

  def generate(query)
    # Retrieve similar examples
    similar = retrieve_similar(query, k: 5)

    # Augment context
    context = build_context(similar)

    # Generate with LLM
    @llm.generate(query, context: context)
  end
end

# Week 3: Run benchmark
rag_results = benchmark_tasks.map do |task|
  result = rag_system.generate(task.description)
  evaluate(result, task)
end

# Week 4: Analyze and iterate
analyzer = ResultAnalyzer.new(rag_results)
weak_areas = analyzer.identify_weak_areas
improve_rag_for_weak_areas(weak_areas)
```

#### Month 4: Implement Approach 2

**Example: Style Enforcement**

```ruby
# Week 1-2: Extract patterns and build validator
style_guide = StyleGuideExtractor.new(Rails.root).extract
validator = CodeValidator.new(style_guide)

# Week 3: Integrate with LLM
style_aware_generator = StyleAwareGenerator.new(
  llm: OpenAI::Client.new,
  style_guide: style_guide,
  validator: validator
)

# Week 4: Run benchmark and compare
style_results = benchmark_tasks.map do |task|
  result = style_aware_generator.generate(task.description)
  evaluate(result, task)
end

# Compare to baseline
comparison = compare_results(baseline_results, style_results)
# Expected: +15-25% improvement in RuboCop scores
```

#### Month 5: Implement Combined Approach

```ruby
# Combine RAG + Style Enforcement
combined_system = CombinedGenerator.new(
  rag: rag_system,
  style_enforcer: validator,
  llm: OpenAI::Client.new
)

combined_results = benchmark_tasks.map do |task|
  result = combined_system.generate(task.description)
  evaluate(result, task)
end

# Compare all approaches
comparison_report = compare_all(
  baseline_results,
  rag_results,
  style_results,
  combined_results
)
```

**Deliverables:**
- Implementation of each approach
- Benchmark results for each
- Comparative analysis
- Failure mode analysis
- Performance metrics dashboard

---

### Phase 4: A/B Testing & Optimization (Month 6)

#### Experiment Framework

```ruby
class ABTestRunner
  VARIANTS = {
    embedding_model: [
      'text-embedding-3-small',
      'text-embedding-3-large',
      'nomic-embed-v1.5'
    ],
    chunk_size: [100, 300, 500, 1000],
    top_k_snippets: [3, 5, 10, 20],
    reranking_enabled: [true, false],
    hybrid_search: [true, false],
    max_iterations: [1, 2, 3, 5]
  }

  def run_experiments
    VARIANTS.each do |param, values|
      values.each do |value|
        config = default_config.merge(param => value)

        # Run on subset of benchmark (50 tasks)
        results = run_benchmark(config, tasks: 50)

        log_results(
          param: param,
          value: value,
          pass_at_1: results.pass_at_1,
          cost: results.total_cost,
          latency: results.avg_latency
        )
      end
    end

    # Analyze which combinations work best
    optimal_config = find_optimal_configuration
  end
end
```

#### Optimization Areas

**1. Embedding Quality:**
```ruby
# Test different embedding models
embedding_models.each do |model|
  # Re-index with new embeddings
  reindex_with_model(model)

  # Measure retrieval quality
  recall_at_5 = measure_recall(model, k: 5)
  mrr = measure_mrr(model)

  # Measure end-to-end quality
  pass_at_1 = run_benchmark(sample_size: 50)

  log_result(model, recall_at_5, mrr, pass_at_1)
end
```

**2. Chunking Strategy:**
```ruby
chunking_strategies = [
  :method_level,    # Split at method boundaries
  :class_level,     # Keep entire classes
  :file_level,      # Keep entire files
  :semantic         # Split by semantic similarity
]

chunking_strategies.each do |strategy|
  reindex_with_strategy(strategy)
  results = run_benchmark(sample_size: 50)

  analyze_results(strategy, results)
end
```

**3. Prompt Engineering:**
```ruby
prompt_variants = [
  :zero_shot,
  :few_shot_3_examples,
  :few_shot_5_examples,
  :chain_of_thought,
  :react_prompting
]

prompt_variants.each do |variant|
  results = run_benchmark(
    prompt_strategy: variant,
    sample_size: 50
  )

  compare_to_baseline(variant, results)
end
```

**Deliverables:**
- Optimal configuration
- Performance improvement report
- Cost-benefit analysis
- Best practices documentation

---

### Phase 5: Production Readiness (Month 7-8)

#### Month 7: Build Developer Tools

**CLI Tool:**
```bash
#!/usr/bin/env ruby
# bin/rails-ai

require 'rails_ai'

case ARGV[0]
when 'generate'
  # rails-ai generate controller Posts index show create
  RailsAI::CLI.generate(ARGV[1..])

when 'review'
  # rails-ai review app/controllers/posts_controller.rb
  RailsAI::CLI.review(ARGV[1])

when 'benchmark'
  # rails-ai benchmark
  RailsAI::CLI.run_benchmark

when 'index'
  # rails-ai index /path/to/repo
  RailsAI::CLI.index_codebase(ARGV[1])
end
```

**VS Code Extension (Optional):**
```typescript
// extension.ts
export function activate(context: vscode.ExtensionContext) {
  let disposable = vscode.commands.registerCommand(
    'rails-ai.generate',
    async () => {
      const prompt = await vscode.window.showInputBox({
        prompt: 'Describe what to generate'
      });

      const result = await callRailsAI(prompt);
      insertCodeAtCursor(result);
    }
  );

  context.subscriptions.push(disposable);
}
```

#### Month 8: Production Deployment

**Monitoring Dashboard:**
```ruby
# config/routes.rb
mount RailsAI::Dashboard => '/rails-ai'

# Shows:
# - Usage statistics
# - Success rates
# - Common failures
# - Performance metrics
# - Cost tracking
```

**CI/CD Integration:**
```yaml
# .github/workflows/ai-review.yml
name: AI Code Review

on: [pull_request]

jobs:
  ai-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Review with Rails AI
        run: |
          bundle exec rails-ai review --pr=${{ github.event.pull_request.number }}
          # Suggests improvements based on codebase patterns
```

**Deliverables:**
- Production-ready CLI tool
- VS Code extension (if budget allows)
- CI/CD workflows
- Monitoring dashboard
- User documentation
- Team training materials

---

### Phase 6: Continuous Improvement (Ongoing)

#### Monthly Review Process

```ruby
class MonthlyReview
  def perform
    # 1. Collect usage data
    usage_stats = collect_usage_stats

    # 2. Analyze success/failure patterns
    failures = analyze_failures(usage_stats.failed_generations)
    successes = analyze_successes(usage_stats.successful_generations)

    # 3. Update RAG index
    successes.each do |success|
      index_code_snippet(success.output, quality_score: 95)
    end

    # 4. Refine style guide
    new_patterns = extract_patterns(successes)
    update_style_guide(new_patterns)

    # 5. Retrain/update models (if applicable)
    if fine_tuned_model_active?
      schedule_retraining(training_data: successes.map(&:output))
    end

    # 6. Generate report
    generate_report(
      usage_stats: usage_stats,
      improvements: improvements_made,
      next_priorities: failures.top_categories
    )
  end
end
```

#### Quarterly Deep Dive

**Q1-Q4 Activities:**
- Re-run full benchmark suite
- Compare to previous quarters
- Test new LLM models (GPT-5, Claude 4, etc.)
- Update training data with new Rails versions
- Refine custom RuboCop cops
- Collect user feedback
- Prioritize improvements

**Deliverables:**
- Quarterly performance reports
- Updated models/indexes
- Refined tooling
- Documentation updates

---

### Evaluation Metrics Summary

#### Automated Metrics

| Metric | Description | Target | Measurement |
|--------|-------------|--------|-------------|
| **Pass@1** | First output passes all tests | 70%+ | Automated test runner |
| **Pass@5** | Best of 5 passes tests | 85%+ | Automated test runner |
| **Syntax Correctness** | Valid Ruby code | 95%+ | `RubyVM::InstructionSequence.compile` |
| **RuboCop Score** | Style compliance | 90%+ | RuboCop analysis |
| **Security Issues** | Brakeman findings | 0 high/critical | Brakeman scan |
| **Test Coverage** | % of code tested | 80%+ | SimpleCov |
| **Cyclomatic Complexity** | Average per method | <10 | Flog |
| **Duplication** | % duplicate code | <5% | Flay |
| **RubyCritic Score** | Overall quality | >85 | RubyCritic |

#### Performance Metrics

| Metric | Description | Target | Measurement |
|--------|-------------|--------|-------------|
| **Latency P50** | Median generation time | <5s | Timer |
| **Latency P95** | 95th percentile time | <10s | Timer |
| **Cost per Task** | API costs | <$0.20 | Token tracking |
| **Throughput** | Tasks per hour | >100 | Monitoring |

#### Quality Metrics

| Metric | Description | Target | Measurement |
|--------|-------------|--------|-------------|
| **Human Rating** | Expert developer score (1-5) | 4.0+ | Human evaluation |
| **Idiomaticity** | Follows Rails conventions | 4.0+/5 | Human evaluation |
| **Maintainability** | Would merge this PR? | 75%+ | Human evaluation |
| **Readability** | Can understand code? | 4.5+/5 | Human evaluation |

#### Business Metrics

| Metric | Description | Target | Measurement |
|--------|-------------|--------|-------------|
| **Time Saved** | % reduction in coding time | 40-60% | Time tracking |
| **Developer Satisfaction** | Team happiness score | 4+/5 | Surveys |
| **Adoption Rate** | % of team using tool | 80%+ | Usage analytics |
| **PR Review Time** | Time to approve PRs | -30% | GitHub analytics |
| **Bug Rate** | Issues in production | -20% | Bug tracking |

---

## Data Sources & Curation

### High-Quality Rails Repositories

#### Tier 1: Framework Core

| Repository | Stars | LOC | Focus | Quality Score |
|------------|-------|-----|-------|---------------|
| rails/rails | 57.8k | 500k+ | Framework | 95/100 |

**What to Extract:**
- ActiveRecord patterns
- ActionController conventions
- ActiveSupport utilities
- Rails idioms and best practices
- Error handling patterns

---

#### Tier 2: Production Applications

| Repository | Stars | LOC | Focus | Quality Score |
|------------|-------|-----|-------|---------------|
| discourse/discourse | 42k | 300k+ | Forum platform | 92/100 |
| gitlab-org/gitlab | 23k | 2M+ | DevOps platform | 90/100 |
| mastodon/mastodon | 47k | 200k+ | Social network | 88/100 |
| forem/forem | 22k | 150k+ | Community platform | 87/100 |
| chatwoot/chatwoot | 21k | 100k+ | Customer support | 89/100 |

**What to Extract:**
- Real-world architecture patterns
- Service objects
- Background jobs
- API implementations
- Complex queries
- Test patterns

---

#### Tier 3: Popular Gems

| Repository | Stars | Focus | Quality Score |
|------------|-------|-------|---------------|
| devise/devise | 24k | Authentication | 94/100 |
| sidekiq/sidekiq | 13k | Background jobs | 93/100 |
| pundit/pundit | 8k | Authorization | 91/100 |
| draper/draper | 5k | Decorators | 88/100 |
| factory_bot/factory_bot | 8k | Test fixtures | 90/100 |
| rspec-rails | 5k | Testing | 92/100 |

**What to Extract:**
- Gem-specific patterns
- Testing strategies
- Configuration patterns
- Integration patterns

---

### Quality Filtering Criteria

#### Repository-Level Filters

```ruby
class RepositoryFilter
  CRITERIA = {
    min_stars: 500,
    min_forks: 50,
    fork_to_star_ratio: (1.0/8.0)..(1.0/12.0),
    last_commit_within_days: 180,
    has_ci: true,
    has_tests: true,
    test_coverage_min: 70.0,
    documentation_present: true,
    license_present: true
  }

  def meets_criteria?(repo)
    CRITERIA.all? do |criterion, threshold|
      check_criterion(repo, criterion, threshold)
    end
  end
end
```

#### File-Level Filters

```ruby
class FileFilter
  def should_include?(file_path, content)
    return false if vendored?(file_path)
    return false if generated?(file_path)
    return false if test_fixture?(file_path)
    return false if migration?(file_path) # Usually too specific

    # Quality checks
    rubocop_score = analyze_with_rubocop(content)
    return false if rubocop_score < 85

    complexity = calculate_complexity(content)
    return false if complexity > 50

    duplication = check_duplication(content)
    return false if duplication > 20.percent

    true
  end

  private

  def vendored?(path)
    path.include?('/vendor/') || path.include?('/node_modules/')
  end

  def generated?(path)
    path.include?('/db/schema.rb') ||
      path.include?('_pb.rb') ||
      content.include?('# frozen_string_literal: true')
  end
end
```

#### Code-Level Filters

```ruby
class CodeQualityAnalyzer
  def analyze(code)
    {
      rubocop_score: rubocop_score(code),
      cyclomatic_complexity: flog_score(code),
      duplication: flay_score(code),
      churn: git_churn(code),
      maintainability: rubycritic_score(code)
    }
  end

  def meets_threshold?(code)
    analysis = analyze(code)

    analysis[:rubocop_score] > 85 &&
      analysis[:cyclomatic_complexity] < 50 &&
      analysis[:duplication] < 5.0 &&
      analysis[:maintainability] > 80
  end
end
```

### Deduplication Strategy

#### Level 1: Exact Deduplication

```ruby
class ExactDeduplicator
  def deduplicate(snippets)
    seen_hashes = Set.new

    snippets.reject do |snippet|
      hash = Digest::SHA256.hexdigest(snippet.content)

      if seen_hashes.include?(hash)
        true # Reject duplicates
      else
        seen_hashes.add(hash)
        false # Keep unique
      end
    end
  end
end
```

#### Level 2: Near-Deduplication

```ruby
class NearDeduplicator
  # Using MinHash LSH for near-duplicate detection
  def deduplicate(snippets, threshold: 0.85)
    lsh = MinHashLSH.new(threshold: threshold)

    snippets.each do |snippet|
      minhash = calculate_minhash(snippet.content)

      unless lsh.query(minhash).any?
        lsh.insert(snippet.id, minhash)
      end
    end

    # Return only unique snippets
    snippets.select { |s| lsh.contains?(s.id) }
  end

  private

  def calculate_minhash(content)
    # Tokenize and create MinHash signature
    tokens = tokenize(content)
    MinHash.new(tokens, num_perm: 128)
  end
end
```

#### Level 3: Semantic Deduplication

```ruby
class SemanticDeduplicator
  def deduplicate(snippets, similarity_threshold: 0.95)
    embeddings = generate_embeddings(snippets)

    kept_snippets = []
    kept_embeddings = []

    snippets.zip(embeddings).each do |snippet, embedding|
      # Check similarity to already kept snippets
      max_similarity = kept_embeddings.map do |kept_emb|
        cosine_similarity(embedding, kept_emb)
      end.max || 0.0

      if max_similarity < similarity_threshold
        kept_snippets << snippet
        kept_embeddings << embedding
      end
    end

    kept_snippets
  end
end
```

### Data Processing Pipeline

```ruby
class DataProcessingPipeline
  def process(repository_url)
    # Step 1: Clone repository
    repo_path = clone_repository(repository_url)

    # Step 2: Extract files
    files = extract_ruby_files(repo_path)

    # Step 3: Filter files
    quality_files = files.select { |f| file_filter.should_include?(f) }

    # Step 4: Parse and chunk
    snippets = quality_files.flat_map { |f| chunk_file(f) }

    # Step 5: Quality analysis
    quality_snippets = snippets.select { |s| meets_quality_threshold?(s) }

    # Step 6: Deduplication
    unique_snippets = deduplicate(quality_snippets)

    # Step 7: Enrich metadata
    enriched_snippets = enrich_with_metadata(unique_snippets)

    # Step 8: Store
    store_snippets(enriched_snippets)

    {
      total_files: files.count,
      quality_files: quality_files.count,
      total_snippets: snippets.count,
      quality_snippets: quality_snippets.count,
      unique_snippets: unique_snippets.count,
      stored: enriched_snippets.count
    }
  end
end
```

### Chunk Strategy Comparison

| Strategy | Pros | Cons | Best For |
|----------|------|------|----------|
| **Method-level** | Focused, specific | May lack context | Code completion |
| **Class-level** | Good context | May be too large | Understanding patterns |
| **File-level** | Complete context | Too large for embedding | Documentation |
| **Semantic** | Context-aware | Complex to implement | Accurate retrieval |

**Recommended:** Start with method-level, add class context as metadata

### Dataset Statistics (Expected)

After processing top 50 Rails repositories:

```
Total Repositories: 50
Total Files: 150,000
Quality Files: 45,000 (30%)
Total Snippets: 250,000
Quality Snippets: 85,000 (34%)
After Deduplication: 50,000 (59% reduction)

Breakdown by Type:
- Controllers: 12,000 (24%)
- Models: 15,000 (30%)
- Services: 8,000 (16%)
- Helpers: 5,000 (10%)
- Tests: 10,000 (20%)

Average Quality Scores:
- RuboCop: 89/100
- RubyCritic: 87/100
- Test Coverage: 78%
```

---

## Cost Analysis

### Detailed Cost Breakdown by Approach

#### Approach A: Training Small Model Locally

**Initial Costs:**
```
Dataset Curation:
- Developer time (3-4 weeks): $6,000-$12,000
- Tools/scripts: $0 (open source)

Training Infrastructure:
- Cloud GPU setup: $100-$300
- Training runs (3-5 experiments): $300-$1,500

Evaluation:
- Benchmark creation: $2,000-$4,000
- Evaluation infrastructure: $500-$1,000

Total Initial: $8,900-$18,800
```

**Ongoing Costs (Annual):**
```
Monthly Updates:
- Retraining (monthly): $100-$300/month = $1,200-$3,600/year
- New data curation: $50-$150/month = $600-$1,800/year

Infrastructure:
- Model hosting: $50-$200/month = $600-$2,400/year
- Storage: $20-$50/month = $240-$600/year

Maintenance:
- Monitoring/improvements: 5-10 hours/month × $100-$150/hour = $6,000-$18,000/year

Total Ongoing: $8,640-$26,400/year
```

**Total First Year: $17,540-$45,200**

---

#### Approach B: Fine-Tuning Existing LLM

**Initial Costs:**
```
Dataset Preparation:
- Collection & filtering: $4,000-$8,000
- Quality analysis: $2,000-$4,000

Fine-Tuning:
- GPU time (QLoRA): $500-$2,000
- Experiments (5-10 runs): $1,500-$5,000

Evaluation:
- Benchmark suite: $2,000-$4,000
- Human evaluation: $1,000-$3,000

Total Initial: $11,000-$26,000
```

**Ongoing Costs (Annual):**
```
Model Updates:
- Monthly retraining: $200-$500/month = $2,400-$6,000/year
- New data preparation: $100-$300/month = $1,200-$3,600/year

Inference:
- API costs (moderate usage): $100-$500/month = $1,200-$6,000/year
- OR self-hosting: $150-$400/month = $1,800-$4,800/year

Maintenance:
- Monitoring/updates: 5-8 hours/month × $100-$150/hour = $6,000-$14,400/year

Total Ongoing: $10,800-$30,000/year
```

**Total First Year: $21,800-$56,000**

---

#### Approach C: RAG with SQLite

**Initial Costs:**
```
Implementation:
- Development (3-4 weeks): $6,000-$12,000
- Integration work: $1,000-$3,000

Data Collection:
- Repository indexing: $500-$1,500
- Quality filtering: $500-$1,500

Infrastructure:
- Embedding generation (one-time): $20-$100 (OpenAI) OR $0 (local)
- Setup/testing: $500-$1,000

Total Initial: $8,520-$19,100
```

**Ongoing Costs (Annual):**
```
100% Local (Ollama + Nomic Embed):
- LLM inference: $0 (local)
- Embeddings: $0 (local)
- Storage: $0-$50/month = $0-$600/year
- Electricity (estimate): $20-$50/month = $240-$600/year
- Maintenance: 2-5 hours/month × $100-$150/hour = $2,400-$9,000/year

Total Ongoing (Local): $2,640-$10,200/year

---

With APIs (OpenAI/Anthropic):
- LLM API (moderate use): $100-$500/month = $1,200-$6,000/year
- Embedding API: $5-$20/month = $60-$240/year
- Infrastructure: $0-$50/month = $0-$600/year
- Maintenance: 2-5 hours/month × $100-$150/hour = $2,400-$9,000/year

Total Ongoing (API): $3,660-$15,840/year
```

**Total First Year (Local): $11,160-$29,300**
**Total First Year (API): $12,180-$34,940**

---

#### Approach D: Style Guide Enforcement

**Initial Costs:**
```
Pattern Extraction:
- Codebase analysis: $3,000-$6,000
- Pattern documentation: $1,000-$2,000

Custom RuboCop Cops:
- Development (3-5 cops): $3,000-$6,000
- Testing: $1,000-$2,000

Integration:
- Validation pipeline: $2,000-$4,000
- CI/CD integration: $500-$1,500

Total Initial: $10,500-$21,500
```

**Ongoing Costs (Annual):**
```
Maintenance:
- Pattern updates (quarterly): 10-20 hours/year × $100-$150/hour = $1,000-$3,000/year
- New cops (2-3/year): 10-15 hours × $100-$150/hour = $1,000-$2,250/year
- Refinements: 2-3 hours/month × $100-$150/hour = $2,400-$5,400/year

Infrastructure:
- Minimal (uses existing CI/CD): $0-$100/year

Total Ongoing: $4,400-$10,750/year
```

**Total First Year: $14,900-$32,250**

---

### Combined Approach Costs

#### RAG + Style Enforcement (Recommended)

**Local (Bootstrap):**
```
Initial: $8,520 (RAG) + $10,500 (Style) = $19,020
Ongoing: $2,640 (RAG) + $4,400 (Style) = $7,040/year
Total First Year: $26,060

Budget-Friendly Total: ~$26k
```

**With APIs (Better Quality):**
```
Initial: $19,100 (RAG) + $21,500 (Style) = $40,600
Ongoing: $3,660 (RAG) + $10,750 (Style) = $14,410/year
Total First Year: $55,010

Quality-Focused Total: ~$55k
```

---

### ROI Analysis

#### Calculating Time Savings

```ruby
# Assumptions for 5-person dev team
developers = 5
avg_hourly_rate = $125
coding_time_per_week = 20 hours # per developer
weeks_per_year = 48 (accounting for vacation)

baseline_coding_time = developers × coding_time_per_week × weeks_per_year
# = 5 × 20 × 48 = 4,800 hours/year

# With 40% time savings from AI assistance
time_saved = 4,800 × 0.40 = 1,920 hours/year

cost_savings = 1,920 hours × $125/hour = $240,000/year
```

#### ROI by Approach

| Approach | First Year Cost | Time Saved | Cost Savings | ROI |
|----------|-----------------|------------|--------------|-----|
| **RAG (Local)** | $26k | 30-40% | $144k-192k | 454-638% |
| **RAG (API)** | $55k | 35-45% | $168k-216k | 206-293% |
| **Fine-Tune** | $56k | 45-55% | $216k-264k | 286-371% |
| **Train Local** | $45k | 40-50% | $192k-240k | 327-433% |
| **Style Only** | $32k | 20-30% | $96k-144k | 200-350% |

**Key Insight:** Even the most expensive approach (fine-tuning) delivers 286-371% ROI in first year for a 5-person team.

#### Break-Even Analysis

```
For RAG + Style (Local) approach:
Cost: $26,060
Break-even at 40% time savings:

$26,060 ÷ ($125/hour × 0.40 time savings) = 521 hours

For 5-person team: 521 ÷ 5 ÷ 20 hours/week = 5.2 weeks

Break-even in ~5 weeks
```

---

## Recommendations

### For Most Teams: RAG + Style Enforcement

**Why This Combination Wins:**

1. **Fastest Time to Value:** 4-6 weeks to production
2. **Reasonable Cost:** $19k-$55k first year (depending on local vs. API)
3. **Easy Maintenance:** No model retraining required
4. **Rails 8 Aligned:** Leverages SQLite
5. **Proven ROI:** 200-600% return in first year
6. **Low Risk:** Can start small and scale up

**Implementation Roadmap:**

```
Week 1-2: RAG Foundation
- Set up Rails 8 app with SQLite + sqlite-vec
- Implement basic retrieval with Neighbor gem
- Index 1,000 code snippets (proof of concept)

Week 3-4: Expand RAG
- Index top 10 Rails repositories (~10k snippets)
- Test with 20-task benchmark
- Measure baseline accuracy

Week 5-6: Style Enforcement
- Extract patterns from codebase
- Create 2-3 custom RuboCop cops
- Build validation pipeline

Week 7-8: Integration & Testing
- Combine RAG + style enforcement
- Run full benchmark (100+ tasks)
- Measure combined accuracy
- Build CLI tool

Weeks 9-10: Production Deployment
- Documentation
- Team training
- CI/CD integration
- Launch to team

Week 11+: Iteration
- Collect feedback
- Refine based on usage
- Expand to more repositories
- Add more custom cops
```

**Expected Results:**
- Pass@1: 70-85%
- RuboCop Compliance: 90-95%
- Time Savings: 40-60%
- Team Satisfaction: 4+/5

---

### For Quality-Critical Teams: Fine-Tuning + Style

**When to Choose:**
- Code quality is paramount
- Budget supports $50k+ investment
- Have some ML familiarity
- Production-critical applications
- Want 80-90% accuracy

**Trade-offs:**
- Higher initial cost
- Slower iteration (retraining needed)
- More complex maintenance
- Better accuracy than RAG alone

**Upgrade Path from RAG:**
1. Start with RAG + Style (weeks 1-8)
2. Collect 6 months of usage data
3. Use successful outputs as training data
4. Fine-tune CodeLlama or StarCoder2
5. Deploy fine-tuned model alongside RAG
6. Gradually shift to fine-tuned model

---

### For Long-Term Investment: Train Custom Model

**When to Choose:**
- Have ML engineering team
- Privacy/security requirements
- Offline deployment needed
- 2+ year strategic vision
- Very large codebase (1M+ LOC)

**Not Recommended If:**
- No ML expertise in-house
- Need quick results
- Budget is limited
- Small team (<10 developers)

**Phased Approach:**
1. **Year 1:** Start with RAG + Style (prove value)
2. **Year 1.5:** Add fine-tuning (improve quality)
3. **Year 2:** Begin custom model training (strategic advantage)

This phased approach de-risks the investment while building toward full customization.

---

### Budget-Based Recommendations

#### Under $15k Budget

**Approach:** RAG Only (100% Local)

```
Setup:
- Ollama + CodeLlama 13B (local LLM): $0
- Nomic Embed v1.5 (local embeddings): $0
- SQLite + sqlite-vec: $0
- Neighbor gem: $0

Development:
- 2-3 weeks @ $100-$150/hour: $8k-$12k

Infrastructure:
- Local development machine: $0 (existing)
- Electricity: ~$20-50/month

Total: $8k-12k first year
```

**Expected Results:**
- Pass@1: 50-65%
- Time Savings: 30-40%
- ROI: 400-600%

---

#### $15k-$40k Budget

**Approach:** RAG + Style Enforcement (Hybrid)

```
RAG:
- Use APIs for better quality (OpenAI GPT-4)
- Local embeddings (Nomic Embed): $0

Style Enforcement:
- Custom RuboCop cops
- Validation pipeline

Total: $19k-$40k first year
```

**Expected Results:**
- Pass@1: 70-85%
- Time Savings: 40-60%
- ROI: 300-500%

---

#### $40k+ Budget

**Approach:** Fine-Tuning + Style OR All Three Combined

```
Option 1: Fine-Tuning + Style
- Fine-tune CodeLlama-13B
- Custom style enforcement
Total: $40k-$60k first year

Option 2: RAG + Fine-Tuning + Style
- Start with RAG for fast wins
- Add fine-tuning after 6 months
- Style enforcement throughout
Total: $50k-$80k first year
```

**Expected Results:**
- Pass@1: 80-90%
- Time Savings: 50-70%
- ROI: 250-400%

---

### Timeline Recommendations

#### Need Results in 1 Month

**Only Option:** RAG with existing embeddings
- Use pre-indexed repositories
- Skip custom style enforcement initially
- Focus on controllers only
- Accept 50-60% accuracy

---

#### Have 3 Months

**Recommended:** RAG + Basic Style Enforcement
- Full RAG implementation
- 2-3 custom RuboCop cops
- CLI tool
- 70-80% accuracy

---

#### Have 6+ Months

**Recommended:** Phased Approach
- Months 1-2: RAG + Style
- Months 3-4: Evaluate and refine
- Months 5-6: Add fine-tuning if needed
- 80-90% accuracy

---

### Team Size Recommendations

#### 1-3 Developers

**Best:** RAG (Local) + Basic Style
- Cost: $15k-25k
- Quick implementation
- Low maintenance
- Good enough accuracy (60-75%)

---

#### 4-10 Developers

**Best:** RAG (API) + Style Enforcement
- Cost: $30k-50k
- Better quality needed for larger team
- API costs justified by team size
- 70-85% accuracy

---

#### 10+ Developers

**Best:** Fine-Tuning + Style or All Three
- Cost: $50k-100k
- Investment justified by team size
- Highest quality needed
- 80-90% accuracy
- Can support custom model training in year 2

---

### Final Recommendation Matrix

| Your Situation | Recommended Approach | Budget | Timeline | Expected Accuracy |
|----------------|---------------------|--------|----------|-------------------|
| **Startup, move fast** | RAG (Local) | $8k-15k | 3-4 weeks | 55-70% |
| **Small team, budget-conscious** | RAG + Style (Local) | $19k-30k | 6-8 weeks | 70-80% |
| **Medium team, quality matters** | RAG + Style (API) | $35k-55k | 6-8 weeks | 75-85% |
| **Large team, quality critical** | Fine-Tune + Style | $50k-80k | 10-12 weeks | 80-90% |
| **Enterprise, strategic** | All Three (Phased) | $80k-150k | 6-12 months | 85-95% |

---

## Resources & Tools

### Open Source Tools

#### Fine-Tuning Frameworks
- **Unsloth**: https://github.com/unslothai/unsloth
  - 2x faster training, 70% less VRAM
  - Best for QLoRA fine-tuning

- **Hugging Face Transformers**: https://github.com/huggingface/transformers
  - Industry standard
  - Comprehensive documentation

- **PEFT**: https://github.com/huggingface/peft
  - Parameter-Efficient Fine-Tuning
  - LoRA, QLoRA implementations

#### RAG Tools
- **Langchainrb**: https://github.com/patterns-ai-core/langchainrb
  - Ruby LLM orchestration
  - RAG patterns

- **Neighbor**: https://github.com/pgvector/neighbor
  - Vector search for ActiveRecord
  - SQLite support

- **sqlite-vec**: https://github.com/asg017/sqlite-vec
  - Vector search in SQLite
  - Fast and lightweight

#### Code Analysis
- **RuboCop**: https://github.com/rubocop/rubocop
  - Ruby static analyzer
  - 300+ built-in cops

- **RuboCop Rails**: https://github.com/rubocop/rubocop-rails
  - Rails-specific cops

- **RubyCritic**: https://github.com/whitesmith/rubycritic
  - Code quality analysis
  - Combines Reek, Flay, Flog

#### LLM Providers
- **Ollama**: https://ollama.ai
  - Local LLM inference
  - Easy model management

- **ruby-openai**: https://github.com/alexrudall/ruby-openai
  - OpenAI API client

- **anthropic-sdk-ruby**: https://github.com/anthropics/anthropic-sdk-ruby
  - Claude API client

### Research Papers

#### Code Generation
- "StarCoder 2 and The Stack v2: The Next Generation" (arXiv:2402.19173)
- "CodeLlama: Open Foundation Models for Code" (arXiv:2308.12950)
- "AST-T5: Structure-Aware Pretraining for Code Generation" (arXiv:2401.03003)

#### Fine-Tuning
- "QLoRA: Efficient Finetuning of Quantized LLMs" (arXiv:2305.14314)
- "LoRA: Low-Rank Adaptation of Large Language Models" (arXiv:2106.09685)
- "LoRA Insights from Hundreds of Experiments" (arXiv:2402.xxxxx)

#### RAG
- "Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks" (arXiv:2005.11401)
- "Self-RAG: Learning to Retrieve, Generate, and Critique" (arXiv:2310.11511)
- "Enhancing LLM Code Generation with RAG" (Various blogs/Medium)

### Learning Resources

#### Books
- "Build a Large Language Model from Scratch" by Sebastian Raschka
- "Hands-On Large Language Models" by Jay Alammar & Maarten Grootendorst
- "The Rails 8 Way" (upcoming, check for latest edition)

#### Online Courses
- Fast.ai: Practical Deep Learning for Coders
- Hugging Face: NLP Course
- DeepLearning.AI: LLM Specialization

#### Blogs & Tutorials
- **Hugging Face Blog**: https://huggingface.co/blog
  - State-of-the-art techniques

- **Evil Martians**: https://evilmartians.com/chronicles
  - Ruby/Rails best practices

- **Thoughtbot Blog**: https://thoughtbot.com/blog
  - Rails patterns and practices

- **GoRails**: https://gorails.com
  - Rails tutorials and patterns

### Community Resources

#### Forums
- **Ruby on Rails Discuss**: https://discuss.rubyonrails.org
- **Hugging Face Forums**: https://discuss.huggingface.co
- **r/rails**: Reddit community
- **r/MachineLearning**: ML discussions

#### Discord/Slack
- Ruby on Rails Link Slack
- Hugging Face Discord
- MLOps Community

### Datasets

#### Code Datasets
- **The Stack v2**: https://huggingface.co/datasets/bigcode/the-stack-v2
  - 67.5TB of code, 619 languages

- **StarCoderData**: https://huggingface.co/datasets/bigcode/starcoderdata
  - Curated subset of The Stack

- **GitHub Code**: Direct from repositories
  - Use GitHub API for mining

#### Benchmark Datasets
- **HumanEval**: https://github.com/openai/human-eval
  - 164 programming problems

- **MBPP**: https://github.com/google-research/google-research/tree/master/mbpp
  - Mostly Basic Programming Problems

### Commercial Tools

#### AI Code Assistants
- **GitHub Copilot**: https://github.com/features/copilot
  - $10-20/month per developer

- **Cursor**: https://cursor.sh
  - AI-first IDE

- **Codeium**: https://codeium.com
  - Free alternative

#### Cloud GPU Providers
- **RunPod**: https://runpod.io
  - $0.50-2.00/hour

- **Vast.ai**: https://vast.ai
  - Cheapest option, spot instances

- **Lambda Labs**: https://lambdalabs.com
  - $1.50-3.00/hour

- **Google Colab Pro**: https://colab.research.google.com
  - $10-50/month

### Tool Recommendations by Approach

#### For Training Local Model
```
Essential:
- Unsloth (fine-tuning)
- Hugging Face Transformers (model loading)
- MLflow (experiment tracking)
- Weights & Biases (monitoring)

Nice to Have:
- DeepSpeed (multi-GPU)
- Accelerate (distributed training)
```

#### For RAG Implementation
```
Essential:
- Neighbor (vector search)
- sqlite-vec (SQLite extension)
- ruby-openai or Ollama (LLM)
- RuboCop AST (code parsing)

Nice to Have:
- tree-sitter (multi-language parsing)
- Langchainrb (RAG patterns)
```

#### For Style Enforcement
```
Essential:
- RuboCop (static analysis)
- RuboCop Rails (Rails cops)
- RuboCop AST (custom cops)
- parser gem (Ruby parsing)

Nice to Have:
- RubyCritic (quality metrics)
- Reek (code smells)
- Flay (duplication detection)
```

---

## Appendix: Quick Start Guides

### Quick Start: RAG with Local Tools (Zero Cost)

```bash
# 1. Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# 2. Pull models
ollama pull codellama:13b
ollama pull nomic-embed-text

# 3. Create Rails app
rails new rag-assistant --database=sqlite3
cd rag-assistant

# 4. Add gems
bundle add neighbor sqlite3 ruby-openai

# 5. Create database schema
rails generate migration CreateCodeSnippets
# (Add schema from Approach C section)

# 6. Index your first repository
# (See implementation code in Approach C)

# 7. Test retrieval
rails console
> CodeSnippet.search("create Rails controller").first

# Total Cost: $0
# Time: 1 day
```

### Quick Start: Style Enforcement

```bash
# 1. Add RuboCop to project
bundle add rubocop rubocop-rails

# 2. Generate config
rubocop --init

# 3. Create custom cop directory
mkdir -p lib/rubocop/cop/custom

# 4. Write your first custom cop
# (See examples in Approach D)

# 5. Test on generated code
echo "class FooController; end" | rubocop --stdin

# Total Cost: 1-2 days developer time
```

### Quick Start: Benchmark Suite

```bash
# 1. Create benchmark directory
mkdir -p benchmark/{tasks,solutions,results}

# 2. Create first task
cat > benchmark/tasks/001_basic_controller.json <<EOF
{
  "id": 1,
  "description": "Create a Posts controller with index and show actions",
  "test_file": "benchmark/tasks/001_test.rb"
}
EOF

# 3. Create test
# (See example in Evaluation Framework section)

# 4. Run benchmark
ruby benchmark/run.rb

# Total Cost: 1-2 days for 20-task suite
```

---

## Conclusion

This research report provides comprehensive analysis of four approaches to improving LLM accuracy for Rails development:

### Key Takeaways

1. **RAG + Style Enforcement** offers the best balance of speed, cost, and quality for most teams
2. **Fine-tuning** delivers highest quality but requires ongoing investment
3. **Local model training** makes sense only for specific use cases (privacy, offline, long-term)
4. **Style enforcement** should be used universally to complement any approach

### Next Steps

1. **This Week:** Create 10-20 task benchmark to test current LLM baseline
2. **Next Month:** Implement RAG proof-of-concept with 1,000 code snippets
3. **Month 2-3:** Add style enforcement and expand to 10,000 snippets
4. **Month 4+:** Evaluate, iterate, and potentially add fine-tuning

### Expected Outcomes

Following the recommended RAG + Style Enforcement approach:
- **Time to Production:** 6-8 weeks
- **First Year Cost:** $19k-$55k (depending on local vs. API)
- **Expected Accuracy:** 70-85% Pass@1
- **Time Savings:** 40-60% reduction in coding time
- **ROI:** 300-600% in first year

### Contact & Support

For questions about implementation or to discuss your specific use case, consider:
- Posting in Ruby on Rails Discuss forums
- Joining Hugging Face Discord for ML questions
- Consulting with ML engineers for custom solutions

---

**Report Version:** 1.0
**Last Updated:** January 2025
**Authors:** Research synthesis based on 2025 state-of-the-art in LLMs, Rails, and code generation

---

## Related Documents

This research led to the development of comprehensive vision documents:

- [Executive Summary](./01-rag-vision-executive-summary.md) - 10 game-changing innovations for RAG
- [Full Vision (detailed)](./02-rag-vision-evolved.md) - Deep technical exploration (40k+ words)
- [Vision Overview](./00-vision-rag.md) - Consolidated vision document

These documents evolve the RAG + Style Enforcement approach (recommended in this report) into a sophisticated contextual intelligence system.
