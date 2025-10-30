# The Feedback Agent - Vision Document

**Version:** 1.3
**Date:** 2025-10-19
**Author:** Product Team
**Status:** Approved
**Changelog:**
- v1.3: Latest implementation decisions - Cloudflare bot management (CAPTCHA removed), combined AI processing, email encryption
- v1.2: Updated technical references for Rails 8.1 implementation, cookie-based rate limiting, abuse reporting
- v1.1: Added sender email tracking, bot protection, rate limiting, and abuse prevention requirements
- v1.0: Initial product vision

---

## Product Overview

The Feedback Agent is a responsive web application that enables anyone to provide constructive feedback anonymously to any person via email. The platform removes barriers to honest communication by protecting the identity of both feedback providers and recipients, while using AI to enhance constructiveness and prevent abuse.

Unlike traditional feedback systems that require accounts, organizational structures, or face-to-face confrontation, this system allows one-time, person-to-person anonymous communication. Users can provide feedback to coworkers, managers, teachers, coaches, family members, service providers, or anyone else without fear of retaliation or judgment.

The system uses AI in two critical ways: (1) to improve the constructiveness and clarity of feedback while disguising writing style, and (2) to block illegal content, hate speech, and abusive language before delivery.

---

## Problem Statement

### What problem are we solving?

People frequently need to provide honest, constructive feedback but are prevented from doing so by fear of retaliation, damaged relationships, or social consequences. This creates a "feedback gap" where important information never reaches the people who need it most.

**Real-world example:** A parent needs to provide feedback to their child's football coach about coaching methods but fears retaliation against their child if they speak up directly. The feedback never gets shared, the problem persists, and the child's experience suffers.

### Who has this problem?

- **Parents** needing to give feedback to teachers, coaches, or school administrators
- **Employees** wanting to provide upward feedback to managers or leaders
- **Customers** with constructive criticism for businesses but who avoid public reviews
- **Family members** needing to share difficult truths with relatives
- **Coworkers** with peer feedback that could damage working relationships if attributed
- **Community members** wanting to provide feedback to organizations, churches, or local leaders
- **Partners/Spouses** who need a neutral way to initiate difficult conversations

### How are they solving it today?

They aren't. The current options are:

1. **Direct confrontation** - Requires courage, risks retaliation, can damage relationships
2. **Indirect communication** - Through third parties, often gets distorted or dismissed
3. **Public forums/reviews** - Not truly anonymous, creates public conflict
4. **Anonymous notes/letters** - Unprofessional, easy to dismiss, no verification
5. **Silence** - Most common response - feedback never gets shared at all

### Why does this matter?

**For individuals:** Unshared feedback means problems persist, conflicts escalate, and relationships deteriorate. People suffer in silence rather than risk confrontation.

**For organizations:** Leaders and institutions operate with blind spots. Without anonymous feedback channels, they never learn about problems until they become crises.

**For society:** A culture that discourages honest feedback creates environments where dysfunction, abuse, and poor performance go unchecked.

---

## Target Users

### Primary User Profiles

**Profile 1: The Concerned Parent**
- Has children in schools, sports programs, or activities
- Observes problems with coaching, teaching, or program management
- Wants to provide constructive feedback but fears impact on child
- Values: Child's safety and experience, fairness, constructive improvement
- Technical comfort: Medium - uses email and basic web apps regularly

**Profile 2: The Employee with Upward Feedback**
- Works in organization with power dynamics (employee → manager → leadership)
- Sees opportunities for improvement but fears career consequences
- Wants to contribute to organizational success without personal risk
- Values: Professional growth, organizational health, psychological safety
- Technical comfort: High - uses workplace tools daily

**Profile 3: The Customer with Constructive Criticism**
- Receives service from businesses, professionals, or organizations
- Has genuine feedback that could improve service quality
- Doesn't want confrontation or public negative review
- Values: Quality service, fairness, constructive dialogue
- Technical comfort: Medium - comfortable with online forms and email

**Profile 4: The Family Member**
- Needs to share difficult truths with relatives (addiction, behavior, health)
- Wants to be heard without causing family conflict
- Seeking a neutral, non-confrontational communication channel
- Values: Family harmony, honesty, care for loved ones
- Technical comfort: Low to Medium - needs simple, clear interfaces

**Profile 5: The Community Member**
- Involved with churches, clubs, volunteer organizations, or local institutions
- Observes issues that need addressing at organizational level
- Wants to help improve without being seen as troublemaker
- Values: Community health, constructive change, maintaining relationships
- Technical comfort: Variable - interface must be universally accessible

---

## Core Use Cases

### Use Case 1: Parent to Coach Feedback

**Actor:** Jennifer, mother of a 12-year-old on middle school football team

**Context:** Jennifer observes that the coach consistently benches certain players for entire games, including her son, despite all players being on the team to learn and participate. She believes the coach's win-focused approach is hurting player development and team morale. She wants to provide feedback but fears the coach will retaliate against her son.

**Steps:**
1. Jennifer visits the anonymous feedback website
2. She enters the coach's email address (found on school website)
3. **She optionally enters her own email** to receive confirmation and track if coach responds
4. She writes her feedback: "I've noticed that several players, including my son, sit the bench for entire games. While winning is important, these kids joined to learn football and gain experience. Could you consider rotating players more to give everyone playing time?"
5. The AI system reviews her feedback, suggests more constructive phrasing, and removes identifying details like "my son"
6. Jennifer reviews AI suggestions, makes adjustments, and submits
7. AI performs final safety check (no hate speech, no illegal content)
8. **Jennifer receives confirmation email** with copy of her feedback and private link to check status
9. System sends feedback anonymously to coach's email with link to view (coach never sees Jennifer's email)
10. Coach receives email, clicks link, reads feedback in private admin view
11. Coach decides to respond (also improved by AI)
12. **Jennifer receives notification** that coach responded, with link to view response

**Outcome:** Jennifer's feedback reaches the coach without risk to her son. The coach receives constructive criticism in a private, non-confrontational format. Even if he disagrees, he's been made aware of parent concerns.

**Frequency:** One-time feedback, though Jennifer might use system again for other situations

### Use Case 2: Employee to Manager Feedback

**Actor:** Marcus, software engineer reporting to a micromanaging team lead

**Context:** Marcus's manager, Sarah, sends Slack messages late at night expecting immediate responses, schedules unnecessary status meetings multiple times daily, and reviews every code commit in excessive detail. This is affecting Marcus's productivity and work-life balance. Other team members feel the same but nobody wants to speak up and risk their performance reviews.

**Steps:**
1. Marcus decides to provide anonymous feedback after a particularly frustrating week
2. He goes to the anonymous feedback site and enters Sarah's work email
3. He writes detailed feedback about specific behaviors and their impact
4. AI system helps him reframe statements: "You micromanage everything" becomes "I've noticed detailed oversight on tasks where I could work more independently"
5. AI also disguises his writing style (Marcus tends to use certain phrases that might identify him)
6. Marcus reviews, approves, and submits
7. System blocks any potentially identifying metadata
8. Sarah receives email notification about anonymous feedback
9. She logs into admin portal and reads the feedback privately
10. She decides to respond, acknowledging the concern and explaining she's been under pressure from upper management but will try to give more autonomy

**Outcome:** Sarah receives honest feedback she wouldn't have gotten through normal channels. Marcus feels heard without risking his career. Sarah's response (while not solving everything) shows she received the message.

**Frequency:** One-time, though Marcus or coworkers might use it again if behavior doesn't improve

### Use Case 3: Community Member to Church Leadership

**Actor:** Robert, 45-year-old member of local church for 8 years

**Context:** Robert's church has a pastor who frequently makes political statements from the pulpit that Robert feels are divisive and inappropriate for worship services. He's talked with other members who agree but nobody wants to be the one to complain to church leadership. Robert values his church community and doesn't want to leave, but he believes the pastor's political sermons are driving people away.

**Steps:**
1. Robert visits the anonymous feedback website
2. He enters the church's general contact email (found on church website)
3. He writes feedback about specific instances and explains his concern
4. AI helps him stay constructive: "The pastor needs to stop pushing politics" becomes "I've noticed increasing political content in sermons, which makes me and others uncomfortable during worship"
5. System ensures no identifying information or church-specific jargon that might identify him
6. Robert submits the feedback
7. Church administrator receives the email and forwards to appropriate leadership
8. Church leadership reads feedback in admin portal
9. They discuss internally and decide to respond, thanking Robert for feedback and explaining their perspective on faith and public issues

**Outcome:** Church leadership receives feedback they wouldn't hear directly. Robert exercised his voice without risking his standing in the community. Whether or not behavior changes, leadership now knows how some members feel.

**Frequency:** One-time feedback, though could be used for other church matters

### Use Case 4: Customer to Business Owner

**Actor:** Lisa, customer of a local dental practice

**Context:** Lisa has been going to the same dentist for 5 years and likes the quality of care, but the front desk staff is consistently rude and dismissive. She's heard other patients complain in the waiting room. She wants to let the dentist/owner know about the problem but doesn't want awkwardness during future appointments.

**Steps:**
1. Lisa uses the anonymous feedback system
2. She enters the dental practice's business email
3. She describes specific instances of poor customer service at front desk
4. AI helps her be constructive and specific rather than just complaining
5. She submits the feedback
6. Dental practice owner receives email notification
7. Owner reads detailed feedback about front desk behavior
8. Owner responds to acknowledge the feedback and explain they'll address it with staff

**Outcome:** Dentist learns about a serious customer service issue affecting patient retention. Lisa provided valuable feedback without creating awkward future appointments. The business has opportunity to improve.

**Frequency:** One-time, though Lisa might use it again if problems persist or for other businesses

### Use Case 5: Spouse to Spouse

**Actor:** David, married to Karen for 15 years

**Context:** David loves his wife but has been bothered by her increasingly critical comments about his weight, appearance, and habits. He's tried to bring it up but she gets defensive. He wants to communicate how her comments make him feel but needs a neutral, non-confrontational way to start the conversation.

**Steps:**
1. David uses the anonymous feedback system
2. He enters Karen's email address
3. He writes about how certain comments make him feel
4. AI helps him use "I feel" statements and constructive framing
5. He submits the feedback
6. Karen receives email about anonymous feedback
7. She reads it and recognizes it might be from David (or could be from someone else in her life)
8. She responds thoughtfully, apologizing and explaining she didn't realize impact
9. This opens door for them to have actual conversation in person

**Outcome:** David communicated difficult feelings in a format that reduced defensiveness. Karen received feedback in a way that allowed reflection before reacting. They can now have productive conversation.

**Frequency:** Occasional use for difficult conversations

---

## Success Criteria

### Metrics That Matter

**User Success:**
- Feedback completion rate: > 80% of users who start writing feedback complete and submit it
- Feedback constructiveness: > 90% of submitted feedback passes AI constructiveness check without major revisions
- Recipient engagement: > 60% of recipients click through email to read full feedback
- Response rate: > 30% of recipients choose to respond to feedback
- Repeat usage: > 40% of users return to give or receive additional feedback within 6 months

**Platform Quality:**
- System uptime: > 99.5%
- Email delivery rate: > 98% of feedback emails successfully delivered
- Load time: Main feedback page loads in < 2 seconds on average connection
- Mobile responsiveness: Fully functional on screens from 320px to 2560px wide
- AI processing time: Feedback improvement suggestions appear in < 3 seconds

**Safety and Privacy:**
- Content blocking accuracy: > 99% of hate speech and illegal content blocked
- False positive rate: < 2% of legitimate feedback incorrectly blocked
- Identity protection: Zero instances of sender/recipient identity disclosure
- Data security: Zero data breaches or unauthorized access incidents

**Business Success (Future):**
- Organic growth: Word-of-mouth drives > 50% of new users
- Email verification rate: > 90% of recipients verify their email to access feedback
- Conversion to organizational use: > 10% of users inquire about team/company features (V2+)

### What "Good" Looks Like

**In 3 months, success means:**
- 100+ pieces of feedback successfully delivered
- Strong user testimonials about feeling safe to share difficult feedback
- No major security, privacy, or abuse incidents
- Smooth user experience with minimal support requests
- Positive feedback from both senders and recipients about AI helpfulness
- Clear evidence that feedback reached people who wouldn't have received it otherwise

**In 6 months, success means:**
- 500+ pieces of feedback delivered
- Growing through word-of-mouth (minimal marketing spend)
- Media coverage or case studies about successful feedback outcomes
- Requests for organizational/enterprise features
- Data showing high satisfaction on both sender and recipient sides
- Demonstrated use cases across all primary user profiles (parents, employees, customers, etc.)

**In 12 months, success means:**
- 2,000+ pieces of feedback delivered
- Recognized as the go-to solution for anonymous constructive feedback
- Revenue-positive (if monetization implemented)
- Strong reputation for privacy, safety, and constructiveness
- Beginning to expand into organizational feedback systems (V2)
- Measurable positive impact: relationships improved, problems solved, voices heard

---

## Scope

### In Scope (V1 - MVP)

**Core Features:**

1. **Single-Page Feedback Submission**
   - Clean, minimalist interface with clear call-to-action
   - Recipient email address input with validation
   - **Optional sender email field** - if provided, sender receives confirmation email with copy of feedback and private link
   - Multi-line text area for feedback (500-2000 character range)
   - **AI-powered feedback improvement** - Single combined API call for safety + improvement
   - Real-time character count
   - Preview of improved feedback before submission
   - **Bot protection via Cloudflare edge-level management** (no CAPTCHA needed for most users)
   - One-click submit button
   - **Cookie-based visitor tracking** for abuse prevention (persistent, anonymous, HttpOnly)
   - **Rate limiting** via Rails 8.1 built-in: 3 per sender-recipient pair per 24hr, 10 per sender per hour globally

2. **AI-Powered Content Enhancement with Review Interface** (F-006)
   - **Single combined AI call** - Safety check + content improvement in one API request (50% cost reduction)
   - Analyze feedback for constructiveness
   - Suggest rephrasing for clarity and tone improvement
   - Disguise writing style to protect sender identity
   - **Show side-by-side comparison** of original vs AI-improved content
   - **User reviews and approves** before submission (not automatic)
   - **Edit and reprocess** capability for iterative refinement
   - Detect and block hate speech, threats, and illegal content
   - Provide explanation when content is blocked
   - **Multi-provider AI support**: Anthropic Claude Sonnet 4 (default) and OpenAI GPT-4
   - **Auto-detection**: Checks for API keys (Anthropic → OpenAI → Mock)
   - Easy provider switching via configuration (`AI_PROVIDER` env var)

3. **Anonymous Email Delivery**
   - Send notification email to recipient with feedback preview
   - Include secure link to view full feedback
   - Email comes from noreply@system domain
   - No tracking pixels or identifying metadata
   - Professional email template design via ActionMailer

4. **Private Admin Portal for Recipients**
   - Secure access via unique link (no login required initially)
   - Clean interface to read full feedback
   - Display timestamp (without timezone that might identify sender)
   - One-time response capability
   - AI-powered response improvement (same as feedback)
   - Send response back anonymously via system

5. **Identity Protection System**
   - No user accounts or login required (V1)
   - **Cookie-based visitor tracking** for abuse prevention only (persistent, HttpOnly, 1-year expiration)
   - **IP addresses stored temporarily** for gross abuse detection (20/hour threshold), then deleted
   - No tracking pixels or analytics cookies
   - No email headers that reveal sender
   - Secure token-based access for recipients (Rails signed tokens)
   - All communication through system - no direct email reply
   - **Sender email encryption**: AES-256-GCM encryption at rest for maximum privacy
   - **Optional sender tracking**: If sender provides email, system generates unique tracking token to:
     - Link their submissions for helpful reminders on subsequent feedback
     - Enable viewing feedback history via private link
     - **Never reveal sender identity to recipient**

6. **Abuse Prevention and Bot Protection** (F-008)
   - **Cloudflare edge-level bot management**: Primary bot protection at CDN level (no user friction)
   - **Cookie-based visitor tracking**: Persistent cookie identifies returning visitors
     - HttpOnly, Secure, SameSite=Lax for security
     - 1-year expiration, auto-renewed on visits
     - Primary identifier for rate limiting (works with or without sender email)
   - **Smart rate limiting** via Rails 8.1 built-in:
     - **Sender-recipient pair**: 3 submissions per 24 hours (prevents targeted harassment)
     - **Global sender limit**: 10 submissions per hour across all recipients (prevents spam campaigns)
     - **Cookieless submissions**: 2 submissions per hour per IP (stricter for privacy browsers)
     - **IP abuse detection**: 20 submissions per hour (catches bot attacks)
   - **Bot detection** via behavioral analysis (timing, form interaction patterns)
   - **Honeypot fields** (invisible to humans, catch automated bots)
   - **Submission velocity checks** (flag submissions completed suspiciously fast)
   - **CAPTCHA fallback**: Optional for cookieless edge cases (most users never see it)

7. **Recipient Abuse Reporting and Protection** (F-009)
   - **Report abuse button** on feedback view page for recipients
   - **Recipient block list**: Prevents future feedback from being delivered
   - **Three blocking levels**:
     - Full block: Recipient receives no feedback from anyone
     - Sender-specific block: Block specific sender-recipient pairs only
     - Temporary block: Auto-expires after staff review
   - **Email notifications**: Confirmation when added to block list
   - **Block status display**: Recipients see their protection status in UI
   - **Staff review workflow**: Admin review of abuse reports with ability to adjust block levels
   - **Appeal process**: Recipients can request unblock after period of time

8. **AI Content Safety**
   - AI content filtering for hate speech, threats, harassment
   - Illegal content detection (threats of violence, illegal activity)
   - Human-readable explanation when content is blocked
   - Integrated with abuse reporting system (F-009)

9. **Modern Minimalist Design**
   - Clean, uncluttered interface
   - Mobile-first responsive design (320px to 2560px+)
   - Accessibility compliance (WCAG 2.1 AA)
   - Fast loading times (< 2 seconds)
   - Clear visual hierarchy
   - Trustworthy, professional appearance
   - Simple color scheme (primary, secondary, neutral)
   - Clear typography with excellent readability
   - **ViewComponent + DaisyUI** for consistent, accessible, testable UI components

10. **Essential Email Notifications**
   - **Sender confirmation email** (when sender provides email):
     - Confirmation that feedback was submitted
     - Full copy of submitted feedback for sender's records
     - Private link to view feedback status and any response
     - Reminder that identity is protected and never shared
   - **Recipient notification email**:
     - Alert that anonymous feedback has been received
     - Preview snippet of feedback (first 150 characters)
     - Secure link to view full feedback in private portal
   - **Response notification email** (when recipient responds and sender provided email):
     - Alert that recipient has responded
     - Link to view response in private portal
   - ActionMailer with plain HTML + text templates
   - Mobile-friendly email design
   - All emails clearly branded and professional

### Future Scope (V2+)

**Nice-to-Have Features:**

- **User Accounts (Optional)**
  - Track feedback sent and received
  - View response history
  - Manage notification preferences
  - Still maintain anonymity between sender/recipient

- **Feedback Forms and Templates**
  - Pre-built feedback templates for common situations
  - Custom feedback forms with multiple questions
  - Rating scales or structured feedback options
  - Anonymous surveys

- **Organizational Features**
  - Company-wide feedback systems
  - Team feedback collection
  - Manager feedback dashboards
  - Anonymous suggestion boxes
  - Organizational analytics (aggregate, non-identifying)

- **Advanced Analytics**
  - Sentiment analysis of feedback trends
  - Common themes across feedback
  - Response rate metrics
  - Constructiveness scoring
  - Impact measurement

- **Enhanced Response Features**
  - Multi-turn conversations (2-3 exchanges)
  - Ability for sender to ask follow-up questions
  - Moderated dialogue option
  - Third-party mediation for sensitive issues

- **Integrations**
  - Slack/Teams notifications
  - API for embedding in other platforms
  - CRM integrations for customer feedback
  - HR system integrations

- **Premium Features** (Paid Tiers - Post-MVP)
  - Unlimited submissions (vs 3 per day free tier)
  - Priority AI processing
  - Advanced customization options
  - White-label versions for organizations
  - Dedicated support
  - Custom email domains
  - Advanced analytics and reporting
  - Bulk feedback campaigns

### Explicitly Out of Scope (V1)

**We are NOT building:**

- **Public feedback or reviews** - This is not Yelp or Glassdoor. All feedback is private and one-to-one.

- **Social features** - No profiles, no friends, no following, no feeds, no likes/comments.

- **Real-time chat** - Feedback is asynchronous. No instant messaging or live chat.

- **Group feedback** - V1 is person-to-person only. No team feedback, 360 reviews, or group surveys.

- **Identity verification** - No requirement to prove who you are. System relies on honor system and email delivery.

- **Payment processing** - V1 is free to use. No paid plans, subscriptions, or premium features yet.

- **Mobile apps** - Responsive web only. Native iOS/Android apps are future consideration.

- **File attachments** - Text feedback only. No images, documents, videos, or other files.

- **Translation services** - English only for V1. Multi-language support is V2+.

- **Video/voice feedback** - Text only. No audio or video recording capabilities.

- **Feedback marketplace** - No public directory, no browsing others' feedback, no feedback "discovery."

- **Gamification** - No points, badges, leaderboards, or rewards. Keep it serious and professional.

**Rationale for exclusions:**

We're laser-focused on solving one problem exceptionally well: enabling anonymous, constructive, one-to-one feedback. Every feature above dilutes that focus, adds complexity, or introduces privacy/security concerns. We can revisit these in future versions once we've proven the core concept works.

---

## Key Decisions

### Decision 1: Rails 8.1 as Technology Foundation

**What we decided:** Build the application on Rails 8.1 with the Solid Stack (SolidQueue, SolidCache, SolidCable) and SQLite.

**Why:**
- **Convention over Configuration** - Rails provides battle-tested patterns that accelerate development
- **Solid Stack** - Built-in SQLite-backed infrastructure eliminates external dependencies (no Redis, no PostgreSQL complexity)
- **Proven at Scale** - Basecamp and HEY serve millions of users on this exact stack
- **Developer Velocity** - Single developer can be highly productive with Rails conventions
- **Simple Deployment** - Kamal 2 + Litestream provides production-ready infrastructure
- **Cost Effective** - Fewer services to run and monitor
- **Rapid Iteration** - Hot reload, generators, console access enable fast experimentation

**Stack Components:**
- **Rails 8.1** - Latest stable with Solid libraries built-in
- **SQLite** - Single database file for app data, cache, and background jobs
- **SolidQueue** - Background job processing (no Sidekiq/Redis needed)
- **SolidCache** - Caching layer for rate limiting and performance
- **ActionMailer** - Email generation and delivery via Resend SMTP
- **Hotwire (Turbo + Stimulus)** - Interactive UI without heavy JavaScript
- **Tailwind CSS** - Utility-first CSS framework with custom components
- **Rails Partials & Helpers** - Reusable view components using Rails conventions
- **Minitest** - Fast, simple testing framework (Rails default)

**Trade-offs:**
- SQLite has write concurrency limits (mitigated: app is write-light)
- Less familiar than PostgreSQL/Redis (mitigated: team has strong Rails expertise)
- Smaller ecosystem than Node.js (mitigated: Rails ecosystem is mature and stable)

**Migration path:** Can switch to PostgreSQL by changing `database.yml` if scaling requires it.

**UI Component Strategy:**

We're using **ViewComponent with DaisyUI** for building our user interface:

**Why ViewComponent + DaisyUI:**
- **ViewComponent 4.1.0+** - Rails 8.1 compatible component framework for encapsulation
- **DaisyUI v5** - Production-ready Tailwind CSS component library with accessibility built-in
- **Component Encapsulation** - Logic, templates, and tests co-located for maintainability
- **Testable** - Isolated component tests with `ViewComponent::TestCase`
- **Hotwire Compatible** - Works seamlessly with Turbo and Stimulus
- **Accessible by Default** - DaisyUI components meet WCAG 2.1 AA standards
- **Consistent Design** - Professional UI with minimal custom CSS

**Component Architecture:**
- **Base UI Components** - ViewComponents wrapping DaisyUI in `app/components/ui/`
- **Domain Components** - Feedback-specific components in `app/components/feedback/`
- **Slot-based Composition** - `renders_one`, `renders_many` for flexible APIs
- **Component Tests** - Unit tests in `test/components/`
- **Optional Previews** - Built-in preview system at `/rails/view_components`

**Components We'll Build:**
- **Ui::ButtonComponent** - Buttons with 9 variants, 4 sizes, loading/disabled states
- **Ui::CardComponent** - Cards with title/body/actions slots for consistent layouts
- **Ui::FormFieldComponent** - Form inputs with label/hint/error slots
- **Ui::AlertComponent** - Alerts with 4 variants (info, success, warning, error)
- **Ui::BadgeComponent** - Status indicators with 9 variants
- **Ui::ModalComponent** - Turbo Frame-compatible modals for abuse reporting
- **Feedback::SubmissionFormComponent** - Complete feedback submission form
- **Feedback::MessageCardComponent** - Feedback display card with status

**Implementation Example:**
```ruby
# app/components/ui/button_component.rb
class Ui::ButtonComponent < ViewComponent::Base
  def initialize(variant: :primary, size: :md, **options)
    @variant = variant
    @size = size
    @options = options
  end

  def call
    tag.button(content, class: button_classes, **@options)
  end

  private

  def button_classes
    ["btn", "btn-#{@variant}", size_class].compact.join(" ")
  end

  def size_class
    { xs: "btn-xs", sm: "btn-sm", md: "", lg: "btn-lg" }[@size]
  end
end
```

**Usage:**
```erb
<%= render Ui::ButtonComponent.new(variant: :primary, size: :lg) do %>
  Submit Feedback
<% end %>
```

**Benefits:**
- Modern component architecture with testability
- Beautiful, accessible UI from DaisyUI
- Co-located component logic and templates
- Isolated unit testing without full page renders
- Works perfectly with AI code generation
- Professional design with minimal effort

### Decision 2: No User Accounts (V1)

**What we decided:** V1 will not require user accounts, logins, or authentication for senders. Recipients access feedback via unique secure links generated by Rails.

**Why:**
- Reduces friction - users can give feedback immediately without signing up
- Enhances anonymity - no account data to potentially leak sender identity
- Faster to build - no authentication system, password resets, profile management
- Aligns with use case - most feedback is one-time, doesn't need account tracking

**Trade-offs:**
- Senders can't track feedback they've sent (unless they provide email)
- No user preference management
- Harder to build trust/reputation over time

**Future consideration:** Optional accounts in V2 for users who want to track their feedback history while maintaining anonymity toward recipients.

### Decision 3: AI Review Interface - User Control Over Final Content (F-006)

**What we decided:** All feedback passes through AI processing for improvement and safety via **single combined API call**. **Users review AI suggestions in a comparison interface and must approve before submission.** Users can edit and reprocess iteratively until satisfied. System supports both Anthropic Claude Sonnet 4 (default) and OpenAI GPT-4 with auto-detection.

**Why:**
- **User control and transparency** - Users see exactly what will be sent, building trust
- **Iterative refinement** - Users can refine feedback until they're satisfied
- **Learning tool** - Users see examples of constructive feedback, improving their skills
- **Cost efficient** - Single combined AI call (safety + improvement) reduces costs by 50%
- **Faster processing** - One API round-trip instead of two sequential calls
- **Multi-provider support** - Anthropic Claude (default), OpenAI GPT-4, or Mock (testing)
- **Auto-detection** - Checks API keys in priority order: Anthropic → OpenAI → Mock
- **Provider flexibility** - Switch via `AI_PROVIDER` environment variable
- Core value proposition - AI improvement is what makes our system better than just sending anonymous email
- Safety requirement - AI catches hate speech, threats, illegal content
- Writing style protection - AI disguises identifying writing patterns
- Constructiveness guarantee - system reputation depends on quality feedback

**Trade-offs:**
- Requires AI service costs (OpenAI/Anthropic API)
- Adds extra step to submission process (review interface)
- Could frustrate users who think their original feedback is fine
- Dependency on third-party AI service availability
- More complex UI/UX design needed

**Implementation note:** Service objects for AI provider abstraction, with factory pattern for provider selection. Combined prompt includes both safety and improvement instructions in single request. Background processing via ActiveJob + SolidQueue for async AI calls.

**Resolved:** ✅ Multi-provider support implemented with auto-detection (see Open Question 1)

### Decision 4: Responsive Web App, Not Native Mobile

**What we decided:** Build responsive web application that works on all devices rather than native iOS/Android apps.

**Why:**
- Faster to build and iterate - one codebase
- Universal access - works on any device with web browser
- No app store approval process or delays
- Easier to update - push changes immediately with Rails
- Lower development and maintenance costs
- Sufficient for use case - feedback isn't time-sensitive or needing offline access

**Trade-offs:**
- No push notifications (rely on email)
- Can't access device features (camera, contacts, etc.) - but we don't need these
- Less "premium" feel than native app
- Slightly less performance than native

**Future consideration:** If usage data shows strong mobile preference and request for app, build native versions in V2.

### Decision 5: One Response Only (V1)

**What we decided:** Recipients can respond to feedback once via ActionMailer. No back-and-forth conversation beyond that single exchange.

**Why:**
- Maintains simplicity - one feedback, one response, done
- Reduces moderation needs - fewer opportunities for conversation to turn toxic
- Protects anonymity - more exchanges increase risk of identity discovery
- Focuses intent - feedback is delivered, recipient can acknowledge, conversation can move offline if both parties want

**Trade-offs:**
- Limits dialogue potential
- Can't clarify or ask follow-up questions easily
- Some situations might benefit from extended conversation
- Recipient might want to ask questions before responding

**Future consideration:** V2 could allow 2-3 turn conversations with both parties opting in.

### Decision 6: Cookie-Based Rate Limiting via Rails 8.1 (V1) - REVISED v1.2

**What we decided:** Use Rails 8.1's built-in rate limiting with persistent cookie-based visitor tracking and SolidCache storage: 3 submissions per sender-recipient pair per 24 hours, and 10 submissions per sender per hour globally. No payment required for MVP.

**Why:**
- **Built into Rails 8.1** - Native `rate_limit` controller DSL, no custom middleware
- **SolidCache storage** - Uses SQLite, no Redis needed
- **User-friendly**: Doesn't penalize users behind NAT/corporate firewalls (IP-based would)
- **Targets actual abuse**: Prevents targeted harassment (sender→recipient pairs) and spam campaigns
- **Works universally**: Cookie persists whether sender provides email or not
- **Privacy-conscious**: Cookie is HttpOnly, Secure, used only for abuse prevention
- **Simpler to reason about**: Declarative rate limits in controllers
- **Removes adoption barrier**: Free for everyone, validates product-market fit first

**Rails 8.1 Implementation:**
```ruby
class FeedbackController < ApplicationController
  rate_limit to: 10, within: 1.hour, by: -> { visitor_token }
  rate_limit to: 3, within: 24.hours,
             by: -> { "#{visitor_token}:#{recipient_hash}" },
             only: :create
end
```

**Rate Limiting Rules:**
1. **Sender-recipient pair**: 3 submissions per 24 hours (key: `{visitorToken}:{recipientEmailHash}`)
2. **Global sender**: 10 submissions per hour across all recipients (key: `{visitorToken}`)
3. **Cookieless fallback**: 2 submissions per hour per IP (stricter for privacy browsers)
4. **IP abuse detection**: 20 submissions per hour (catches sophisticated bot attacks)

**Trade-offs:**
- Cookie can be deleted/cleared (but requires effort, acceptable for MVP)
- Incognito mode bypasses cookie (but falls back to stricter IP limits + CAPTCHA)
- Multi-device users get separate limits per device (acceptable edge case)
- Need to disclose cookie usage in privacy policy

**Future consideration:**
- Paid tiers with higher limits (post-MVP)
- Organizational/enterprise plans (V2+)
- Optional accounts for unified tracking across devices
- Free tier remains available forever

### Decision 7: Optional Sender Email with Tracking

**What we decided:** Senders can optionally provide their email address. If provided, they receive confirmation via ActionMailer, feedback copy, and tracking link. This does NOT reveal their identity to recipients.

**Why:**
- **Improves user experience** - senders get confirmation and can review what they sent
- **Enables better rate limiting** - can track per email with SolidCache
- **Reduces bot submissions** - email verification acts as human check (along with CAPTCHA for no-email)
- **Builds trust** - sender has record of their feedback
- **Future feature enablement** - allows reminders for repeat senders, history tracking
- **Still protects anonymity** - recipient never sees sender email

**Trade-offs:**
- Requires sender to trust us with their email
- Adds complexity to system (two paths: with email / without email)
- Email storage increases privacy concerns (mitigated: Rails encrypted attributes)
- Must be clearly optional to not deter users

**Implementation safeguards:**
- Sender email never included in any communication to recipient
- **Sender email encrypted at rest via AES-256-GCM** (Rails encrypted attributes)
- Encryption key managed securely at application level
- Decrypted only when sending emails, never exposed in logs or UI
- Clear privacy policy about email usage
- Option to provide email for confirmation only, then auto-delete after 30 days

**Resolved:** ✅ Email encryption implemented with AES-256-GCM (see Open Question 12)

### Decision 8: Email as Primary Channel via ActionMailer

**What we decided:** All notifications and feedback delivery happen via email using ActionMailer with Resend SMTP. Recipients must have email address.

**Why:**
- Universal - everyone has email
- Professional - email is expected communication channel
- Asynchronous - fits feedback use case (not time-sensitive)
- Verifiable - email addresses can be confirmed as real
- Familiar - users understand email workflow
- Trackable - can see delivery/open rates
- **Rails native** - ActionMailer is mature and well-integrated

**Trade-offs:**
- Email might go to spam (mitigated: Resend has excellent deliverability)
- Requires valid email address (can't use phone number or social media)
- Email is less immediate than SMS or push notifications
- Some recipients might not check email frequently

**Implementation note:** Use Resend SMTP (no gem needed, just SMTP configuration) with proper SPF/DKIM/DMARC configuration to maximize deliverability. Background delivery via ActiveJob + SolidQueue.

### Decision 9: Multi-Layer Bot Protection (Updated v1.3)

**What we decided:** Implement comprehensive bot protection with **Cloudflare edge-level management as primary defense**, supplemented by tracking tokens, rate limiting, honeypots, and behavioral analysis. CAPTCHA only used as fallback for cookieless edge cases.

**Why:**
- **Better UX** - Most users never see CAPTCHA (handled at edge)
- **More effective** - Edge-level detection catches bots before they reach app
- **Simpler architecture** - Fewer client-side scripts and configuration
- **Prevents harassment campaigns** - stops someone from sending 100s of hateful messages
- **Stops DDoS attacks** - protects recipients from being overwhelmed at CDN level
- **Maintains system credibility** - abuse would destroy trust in platform
- **Reduces spam** - automated bots can't flood the system
- **Protects AI costs** - each submission uses expensive AI processing
- **Enables anonymous access** - can offer no-login experience because abuse is controlled

**Multi-layer approach:**
1. **Cloudflare bot management** - Primary defense at edge (automatic, transparent to users)
2. **Tracking tokens** - Rails signed cookies, unique per visitor
3. **Rate limiting** - Rails 8.1 built-in with SolidCache (four-layer strategy)
4. **Honeypot fields** - Hidden form fields catch bots (Rails view helpers)
5. **Behavioral analysis** - Timing and interaction patterns flag bots (Stimulus controllers)
6. **Velocity checks** - Flag submissions completed suspiciously fast (ActiveRecord callbacks)
7. **CAPTCHA fallback** - Optional for cookieless users only (privacy browsers)

**Trade-offs:**
- Dependency on Cloudflare for primary bot protection
- May flag legitimate users as bots (false positives - mitigated by multiple layers)
- Requires Cloudflare configuration and monitoring
- Ongoing tuning needed based on abuse patterns

**Implementation strategy:**
- Cloudflare bot management enabled at edge (one-time setup)
- Start with moderate protection, tune based on observed abuse
- Track metrics on false positive rate (Rails instrumentation)
- Provide clear error messages when blocked (Rails flash messages)
- Allow manual review/appeal process for false positives (ActiveAdmin)

**What changed from v1.2:**
- Removed CAPTCHA from main submission flow
- Added Cloudflare edge-level bot management as primary defense
- CAPTCHA now only fallback for cookieless users
- Simpler user experience (no friction for 95%+ of users)

### Decision 10: Recipient Abuse Reporting System (F-009) - NEW v1.2

**What we decided:** Implement recipient-side abuse reporting with block list functionality, three levels of blocking protection, and staff review workflow.

**Why:**
- **Empowers recipients**: Gives recipients control when they receive abusive or harassing feedback
- **Complements AI safety**: AI catches most abuse, but humans can identify patterns AI misses
- **Creates accountability**: Even anonymous senders know recipients can report abuse
- **Enables escalation**: Staff can review patterns and block repeat offenders
- **Builds trust**: Recipients feel protected, making them more likely to engage with feedback

**Blocking Levels:**
1. **Sender-specific block**: Block feedback from specific visitor token only (targeted harassment)
2. **Full block**: Temporarily block ALL feedback to recipient (overwhelming volume of abuse)
3. **Auto-expire**: Temporary blocks expire after staff review and resolution

**Workflow:**
1. Recipient views feedback and clicks "Report Abuse" button (Turbo Frame)
2. System creates AbuseReport model with feedback_id, recipient_email, timestamp
3. Recipient receives email confirmation via ActionMailer
4. Sender-specific block activated immediately (ActiveRecord callback)
5. Staff reviews report in admin dashboard (ActiveAdmin)
6. Staff can: keep block, remove block, escalate to full block, or add notes
7. Recipient can see block status in UI when viewing any feedback

**Trade-offs:**
- Could be abused by recipients to block legitimate feedback (mitigated by staff review)
- Adds complexity to feedback submission flow (need to check block list before creating)
- Requires admin interface for staff review (mitigated: use ActiveAdmin or Mission Control)
- Need clear appeal process for wrongly blocked senders

**Implementation safeguards:**
- Blocks only affect future submissions, not already-delivered feedback
- Email notifications keep recipients informed (ActionMailer)
- Staff review ensures blocks are justified (ActiveAdmin workflows)
- Block status visible to recipient for transparency (Rails views)
- Audit log of all blocking actions for accountability (PaperTrail gem or custom audit concern)

---

## Open Questions

### Technical Questions

1. **AI Provider Selection:** ✅ RESOLVED - Support both Anthropic Claude Sonnet 4 and OpenAI GPT-4
   - **Status:** IMPLEMENTED (v1.3)
   - Implemented provider interface supporting multiple AI models (F-006)
   - **Combined processing:** Single API call for safety + improvement (50% cost reduction)
   - Claude Sonnet 4 default for safety, OpenAI GPT-4 available for cost/performance optimization
   - Service object pattern with factory for provider selection
   - **Auto-detection:** Checks API keys in priority order: Anthropic → OpenAI → Mock
   - Configurable via `AI_PROVIDER` environment variable

2. **Unique Link Security:** What's the right token length and expiration policy for recipient access links?
   - Use Rails `signed_id` or `has_secure_token`?
   - Token length: 32 characters? UUID?
   - Expiration needed? Or permanent access?
   - Decision needed by: Architecture phase

3. **Rate Limiting Implementation:** Rails 8.1 provides built-in rate limiting, but need to decide:
   - How long to cache IP addresses in SolidCache before deletion? (1 day? 7 days?)
   - Should limits reset at midnight or 24h rolling window? (Rails default: rolling)
   - How to handle VPN/proxy detection?
   - Should we allow appeals for false positives? (need admin interface)
   - Decision needed by: Architecture phase

4. **Bot Protection Strategy:** ✅ RESOLVED - Cloudflare edge-level management with optional CAPTCHA fallback
   - **Status:** IMPLEMENTED (v1.3)
   - **Primary:** Cloudflare edge-level bot management (transparent to users)
   - **Fallback:** Cloudflare Turnstile CAPTCHA only for cookieless users
   - Server-side verification via Rails controller (when needed)
   - Bypassed in test/development environments
   - **Result:** 95%+ of users never see CAPTCHA, better UX

5. **Tracking Token Strategy:** How to implement unique submission tokens?
   - Use Rails signed cookies? (secure, automatic)
   - Use `has_secure_token` on model?
   - Token storage duration (30 days? 90 days? Forever?)
   - Associate tokens with sender emails if provided?
   - Use tokens for future "view your feedback" feature?
   - Decision needed by: Architecture phase

### Product Questions

6. **Sender Email Collection UX:** How to present optional email field without seeming required?
   - Clear "Optional" label sufficient?
   - Explain benefits inline ("Get confirmation & view responses")?
   - Checkbox to opt-in before showing email field?
   - What percentage of users will provide email? (need to estimate)
   - Decision needed by: Feature specification phase

7. **Feedback History Access:** When sender provides email, how long can they access feedback history?
   - 30 days? 90 days? 1 year? Forever?
   - Should old feedback auto-delete for privacy?
   - Sender-controlled deletion option? (Rails destroy action)
   - Decision needed by: Feature specification phase

8. **Feedback Length Limits:** What's minimum and maximum character count for feedback?
   - Too short = not constructive ("you suck")
   - Too long = overwhelming to read and process
   - Current thinking: 500 min, 2000 max
   - Enforced via ActiveRecord validations
   - Decision needed by: Feature specification phase

9. **Content Blocking Transparency:** When AI blocks content, how much detail do we show about why?
   - Too vague = frustrates users who don't understand
   - Too specific = could reveal moderation system weaknesses
   - Need balance between transparency and security
   - Render via Rails flash messages or Turbo Stream
   - Decision needed by: Feature specification phase

### Business/Legal Questions

10. **Terms of Service and Liability:** What legal protections do we need?
   - Users might send illegal content despite our blocking
   - Users might misuse system for stalking/harassment
   - Need clear ToS about acceptable use
   - Need disclaimer about not guaranteeing anonymity
   - Legal review needed by: Before public launch

11. **Data Retention Policy:** How long do we keep feedback and responses?
   - Longer = recipients can reference later
   - Shorter = better for privacy, lower storage costs
   - What about deletion requests? (GDPR compliance)
   - ActiveRecord soft deletes or hard deletes?
   - Decision needed by: Architecture phase

12. **Sender Email Privacy:** ✅ RESOLVED - AES-256-GCM encryption at rest
   - **Status:** IMPLEMENTED (v1.3 - security fix H-2)
   - **Encryption:** AES-256-GCM symmetric encryption using Rails encrypted attributes
   - **Key management:** Application-level secret key, securely stored
   - **Access control:** Decrypted only when sending emails, never exposed in logs or UI
   - **Admin access:** Even database administrators cannot read plaintext emails
   - **Auto-delete:** Optional 30-day deletion if sender doesn't need tracking
   - **Compliance:** Meets GDPR/CCPA encryption at rest requirements
   - **Security standard:** Industry best practice for sensitive data protection

13. **Monetization Strategy:** What's the pricing for paid tiers post-MVP?
   - How much for unlimited submissions? ($5/mo? $10/mo?)
   - Annual vs monthly pricing?
   - Organizational/enterprise plans (V2)
   - Premium features for power users
   - Donations/sponsorships option
   - Grant funding for social good aspect
   - Decision needed by: V2 planning phase (after MVP validation)

---

## Success Definition

**This product is successful when:**

1. **Feedback is flowing:** Hundreds of pieces of feedback are successfully delivered each month, spanning all major use cases (workplace, family, community, customer service).

2. **Users feel safe:** Both senders and recipients report feeling that the system protected their privacy and created a safe environment for honest communication.

3. **Feedback is constructive:** Recipients report that feedback was helpful, specific, and actionable rather than just venting or attacking.

4. **Problems get solved:** We collect stories/testimonials of real issues being addressed because feedback reached the right person anonymously.

5. **Word spreads organically:** Users recommend the system to others facing similar situations. Growth is driven by people saying "I used this tool and it worked."

6. **System is reliable:** No security breaches, no identity leaks, no major technical failures. Users trust the platform.

7. **AI adds value:** Users report that AI improvements made their feedback better, clearer, and more constructive than their original version.

**We'll know we failed if:**

1. **Low completion rate:** Users start writing feedback but abandon before submitting (indicates UX problems or lack of trust).

2. **Low recipient engagement:** Recipients don't click through to read feedback (indicates poor email design or feedback isn't compelling).

3. **Abuse and toxicity:** AI content blocking fails and hateful/abusive feedback gets through regularly.

4. **Identity leaks:** Any instance of sender/recipient identity being compromised destroys trust in entire platform.

5. **No impact stories:** After 6 months, we can't point to examples of real problems being solved or situations improved.

6. **Technical unreliability:** Frequent downtime, failed email deliveries, or AI processing errors frustrate users.

7. **Growth stagnation:** No word-of-mouth growth after initial launch period indicates product doesn't solve real problem.

---

## Next Steps

With this Vision Document complete, the next phases of the Specification Pyramid are:

1. **Architecture Document** - Define Rails 8.1 stack, ActiveRecord models, system architecture, routes, and implementation patterns.

2. **Feature Specifications** - Break down each feature into detailed specs with exact UI (ERB views), ActiveRecord models, controllers, and acceptance criteria.

3. **Task Breakdown** - Create atomic, executable tasks that can be implemented with Rails generators and conventions.

**Timeline:**
- Architecture Document: 1 week
- Core Feature Specs (3-5 features): 1-2 weeks
- Initial Development: 2-3 weeks with Rails generators
- Testing and Refinement: 1 week with Minitest
- **Target MVP Launch: 6-8 weeks from start**

---

## Appendix: Implementation Updates

### F-011: Multi-Step Feedback Submission Flow (Implemented 2025-10-26)

**Status:** Ready for Implementation
**Priority:** P0 (Critical - MVP Blocker)

**Implementation Details:**

The complete feedback submission flow has been specified with the following key architectural decisions:

1. **Real-Time Updates:** Turbo Streams + WebSocket broadcasts (no JavaScript polling)
2. **AI Processing:** Claude Sonnet 4.5 (primary) with GPT-5 fallback for 99.75% uptime
3. **Email Delivery:** Resend SMTP for industry-leading deliverability
4. **Approval Flow:** Users can only approve AI-improved content or start over (no editing)
5. **No Timeouts:** Pending approvals never expire automatically

**User Flow:**
```
1. User submits feedback
   ↓
2. Rate limit and abuse limits checked
   ↓
3. Processing page displayed with real-time updates
   ↓
4. AI analyzes content for safety + improvement
   ↓
5. User reviews original vs AI-improved side-by-side
   ↓
6. User approves → Emails sent via Resend
   ↓
7. Thank you page with delivery confirmation
```

**Technical Highlights:**

- **State Machine:** 7 states (draft, pending, processing, awaiting_approval, approved, delivered, rejected)
- **AI Provider Abstraction:** Unified interface supporting multiple AI providers with automatic failover
- **Background Jobs:** ProcessFeedbackJob, DeliverFeedbackJob via SolidQueue
- **Components:** ViewComponent + DaisyUI for consistent, accessible UI
- **Rate Limiting:** Multi-layer (sender-recipient pair, global sender, IP-based, cookieless fallback)

**See Also:**
- Feature Spec: `docs/features/F-011-feedback-submission-flow.md`
- Task Breakdown: `docs/tasks/F-011-tasks.md`
- Agent Tasks: `docs/tasks/agents/*/F-011-*.md`

**Estimated Implementation Time:** 15-20 hours across 5 phases

---

*End of Vision Document*
