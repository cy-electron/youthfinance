import '../model/learning_resource.dart';

const learningTopics = <String>[
  'Money Basics',
  'Budgeting',
  'Saving',
  'Emergency Fund',
  'Investing',
  'Financial Safety',
];

const learningResources = <LearningResource>[
  // ---------------------------------------------------------------------------
  // MONEY BASICS
  // ---------------------------------------------------------------------------

  LearningResource(
    id: 'money_basics_01',
    topic: 'Money Basics',
    title: 'Personal Finance Basics Everyone Should Understand',
    description:
        'Get a simple introduction to income, spending, saving and the basic ideas behind managing your money.',
    youtubeUrl: 'https://www.youtube.com/watch?v=ZZ56nyc0s_E',
    thumbnailUrl:
        'https://img.youtube.com/vi/ZZ56nyc0s_E/hqdefault.jpg',
    duration: '6 min',
    difficulty: 'Beginner',
  ),

  LearningResource(
    id: 'money_basics_02',
    topic: 'Money Basics',
    title: 'What are Income and Expenses?',
    description:
        'Understand where your money comes from, where it goes, and why tracking both matters.',
    youtubeUrl: 'https://www.youtube.com/watch?v=E2wcbUNZ-yo',
    thumbnailUrl:
        'https://img.youtube.com/vi/E2wcbUNZ-yo/hqdefault.jpg',
    duration: '5 min',
    difficulty: 'Beginner',
  ),

  // ---------------------------------------------------------------------------
  // BUDGETING
  // ---------------------------------------------------------------------------

  LearningResource(
    id: 'budgeting_01',
    topic: 'Budgeting',
    title: 'What Is a Budget?',
    description:
        'Learn how a simple budget can help you understand and control your spending.',
    youtubeUrl: 'https://www.youtube.com/watch?v=xwyqyBXOnOU',
    thumbnailUrl:
        'https://img.youtube.com/vi/xwyqyBXOnOU/hqdefault.jpg',
    duration: '7 min',
    difficulty: 'Beginner',
  ),

  LearningResource(
    id: 'budgeting_02',
    topic: 'Budgeting',
    title: 'Budgeting For Beginners - How To Budget',
    description:
        'Move beyond the basic idea of budgeting and learn practical ways to create and manage a budget.',
    youtubeUrl: 'https://www.youtube.com/watch?v=fOpSiQetTy4',
    thumbnailUrl:
        'https://img.youtube.com/vi/fOpSiQetTy4/hqdefault.jpg',
    duration: '8 min',
    difficulty: 'Intermediate',
  ),

  // ---------------------------------------------------------------------------
  // SAVING
  // ---------------------------------------------------------------------------

  LearningResource(
    id: 'saving_01',
    topic: 'Saving',
    title: 'How to Save Money as a Beginner',
    description:
        'Learn simple and practical ways to start saving money and build a consistent saving habit.',
    youtubeUrl: 'https://www.youtube.com/watch?v=hqWbNSAn1sg',
    thumbnailUrl:
        'https://img.youtube.com/vi/hqWbNSAn1sg/hqdefault.jpg',
    duration: '9 min',
    difficulty: 'Beginner',
  ),

  // ---------------------------------------------------------------------------
  // EMERGENCY FUND
  // ---------------------------------------------------------------------------

  LearningResource(
    id: 'emergency_01',
    topic: 'Emergency Fund',
    title: 'What Is an Emergency Fund?',
    description:
        'Understand what an emergency fund is and how it can protect you from unexpected expenses.',
    youtubeUrl: 'https://www.youtube.com/watch?v=9xJZnoRz8Yk',
    thumbnailUrl:
        'https://img.youtube.com/vi/9xJZnoRz8Yk/hqdefault.jpg',
    duration: '6 min',
    difficulty: 'Beginner',
  ),

  LearningResource(
    id: 'emergency_02',
    topic: 'Emergency Fund',
    title: 'How Much Should You Save For An Emergency Fund?',
    description:
        'Explore how much emergency savings you may need and the factors that can affect that amount.',
    youtubeUrl: 'https://www.youtube.com/watch?v=fA9AzCtvFrs',
    thumbnailUrl:
        'https://img.youtube.com/vi/fA9AzCtvFrs/hqdefault.jpg',
    duration: '8 min',
    difficulty: 'Intermediate',
  ),

  // ---------------------------------------------------------------------------
  // INVESTING
  // ---------------------------------------------------------------------------

  LearningResource(
    id: 'investing_01',
    topic: 'Investing',
    title: 'What is Investing?',
    description:
        'Get a simple introduction to investing and understand why people invest for long-term goals.',
    youtubeUrl: 'https://www.youtube.com/watch?v=Epzr8azlxp8',
    thumbnailUrl:
        'https://img.youtube.com/vi/Epzr8azlxp8/hqdefault.jpg',
    duration: '8 min',
    difficulty: 'Beginner',
  ),

  LearningResource(
    id: 'investing_02',
    topic: 'Investing',
    title: 'What are Mutual Funds?',
    description:
        'Learn how mutual funds work, what they invest in, how returns are generated, and why fees matter.',
    youtubeUrl: 'https://www.youtube.com/watch?v=ugBl0WgmAhg',
    thumbnailUrl:
        'https://img.youtube.com/vi/ugBl0WgmAhg/hqdefault.jpg',
    duration: '8 min',
    difficulty: 'Intermediate',
  ),

  LearningResource(
    id: 'investing_03',
    topic: 'Investing',
    title: 'Understanding Risk and Return',
    description:
        'Learn about the relationship between investment risk and potential returns and why higher risk does not guarantee higher returns.',
    youtubeUrl: 'https://www.youtube.com/watch?v=2-gVKi3hII8',
    thumbnailUrl:
        'https://img.youtube.com/vi/2-gVKi3hII8/hqdefault.jpg',
    duration: '7 min',
    difficulty: 'Intermediate',
  ),

  LearningResource(
    id: 'investing_04',
    topic: 'Investing',
    title: 'What is SIP? SIP Explained in Hindi',
    description:
        'Understand the basic idea of Systematic Investment Plans and how regular investing works with mutual funds.',
    youtubeUrl: 'https://www.youtube.com/watch?v=UzNk9iM7O48',
    thumbnailUrl:
        'https://img.youtube.com/vi/UzNk9iM7O48/hqdefault.jpg',
    duration: '8 min',
    difficulty: 'Beginner',
  ),

  // ---------------------------------------------------------------------------
  // FINANCIAL SAFETY
  // ---------------------------------------------------------------------------

  LearningResource(
    id: 'safety_01',
    topic: 'Financial Safety',
    title: 'What is Identity Theft?',
    description:
        'Learn what identity theft means and how stolen personal information can be misused.',
    youtubeUrl: 'https://www.youtube.com/watch?v=aorPsj3e8ug',
    thumbnailUrl:
        'https://img.youtube.com/vi/aorPsj3e8ug/hqdefault.jpg',
    duration: '5 min',
    difficulty: 'Beginner',
  ),

  LearningResource(
    id: 'safety_02',
    topic: 'Financial Safety',
    title: '5 Tips to Protect Your Financial Information',
    description:
        'Learn practical ways to protect passwords, financial information and accounts from common threats.',
    youtubeUrl: 'https://www.youtube.com/watch?v=CWdBKzvTcuM',
    thumbnailUrl:
        'https://img.youtube.com/vi/CWdBKzvTcuM/hqdefault.jpg',
    duration: '4 min',
    difficulty: 'Intermediate',
  ),
];