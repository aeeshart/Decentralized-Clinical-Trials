# Decentralized Clinical Trials Smart Contract

## Overview

A blockchain-based platform for conducting clinical trials with patient-owned data and transparent results. This smart contract enables patients to maintain control over their medical data while participating in clinical trials with guaranteed compensation and transparent result publication.

## Features

- **Patient Data Ownership**: Patients maintain full control over their medical data
- **Transparent Results**: All trial results are published on-chain for public access
- **Automated Compensation**: Smart contract handles patient compensation automatically
- **Multi-Phase Support**: Supports Phase I through Phase IV clinical trials
- **Decentralized Governance**: No single entity controls the trial data
- **Immutable Records**: All trial data and results are permanently stored on blockchain

## Smart Contract Architecture

### Core Components

1. **Trial Management**: Create, update, and manage clinical trials
2. **Patient Registration**: Secure patient onboarding with consent management
3. **Data Submission**: Encrypted data submission with verification
4. **Compensation System**: Automated STX payments to participants
5. **Results Publication**: Transparent publication of trial outcomes

### Key Data Structures

- `trials`: Complete trial information and metadata
- `patients`: Patient profiles with encrypted medical history
- `trial-enrollments`: Patient-trial relationship tracking
- `patient-data`: Secure data submissions with timestamps
- `trial-results`: Published outcomes and statistical analysis

## Contract Functions

### Read-Only Functions
- `get-trial(uint)`: Retrieve trial information
- `get-patient(uint)`: Get patient profile
- `get-enrollment(uint, uint)`: Check enrollment status
- `get-trial-results(uint)`: Access published results

### Public Functions
- `create-trial()`: Initialize new clinical trial
- `register-patient()`: Patient registration with consent
- `enroll-patient()`: Join a clinical trial
- `submit-patient-data()`: Submit encrypted medical data
- `publish-results()`: Publish trial outcomes
- `pay-compensation()`: Distribute patient payments

## Trial Phases

- **Phase I**: Initial safety testing (20-100 participants)
- **Phase II**: Efficacy and side effect evaluation (100-300 participants)
- **Phase III**: Large-scale effectiveness testing (1,000-3,000 participants)
- **Phase IV**: Post-market surveillance

## Security Features

- Authorization controls for researchers
- Patient consent verification
- Data encryption with hash verification
- Immutable audit trail
- Transparent compensation tracking

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Stacks wallet
- Basic understanding of Clarity smart contracts

### Installation

1. Clone the repository:
```bash
git clone https://github.com/aeeshart/Decentralized-Clinical-Trials.git
cd Decentralized-Clinical-Trials
```

2. Install dependencies:
```bash
clarinet check
```

3. Run tests:
```bash
clarinet test
```

### Deployment

1. Deploy to testnet:
```bash
clarinet deploy --testnet
```

2. Deploy to mainnet:
```bash
clarinet deploy --mainnet
```

## Usage Examples

### Creating a Trial
```clarity
(contract-call? .clinical-trials create-trial 
  "COVID-19 Vaccine Efficacy Study"
  "Phase III randomized controlled trial"
  u3  ;; Phase III
  u1000  ;; Max participants
  u1000000  ;; Start date
  u2000000  ;; End date
  u100000000  ;; Compensation (100 STX)
  "Adults 18-65, healthy"
  "Pregnant women, immunocompromised"
  "Vaccine efficacy rate"
  "Safety profile, antibody response"
)
```

### Patient Registration
```clarity
(contract-call? .clinical-trials register-patient
  u35  ;; Age
  "Female"
  0x1234...  ;; Medical history hash
  0x5678...  ;; Consent hash
)
```

## Compliance & Ethics

- HIPAA compliance through data encryption
- ICH-GCP adherence for clinical trial standards
- FDA CFR Title 21 compliance for US trials
- Patient rights protection through blockchain immutability
- Transparent consent management

## Contributing

We welcome contributions to improve the platform. Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Make your changes with appropriate tests
4. Submit a pull request with detailed description

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Email: aeeshartmohamedmalamee@gmail.com
- GitHub Issues: [Create an issue](https://github.com/aeeshart/Decentralized-Clinical-Trials/issues)

## Roadmap

- [ ] Integration with major EHR systems
- [ ] Mobile app for patient participation
- [ ] Advanced analytics dashboard
- [ ] Multi-chain deployment
- [ ] Regulatory approval automation
- [ ] AI-powered participant matching

## Acknowledgments

- Stacks Foundation for blockchain infrastructure
- Clinical research community for requirements gathering
- Open source contributors and reviewers

---

**Disclaimer**: This smart contract is for research and development purposes. Ensure compliance with local regulations before conducting actual clinical trials.