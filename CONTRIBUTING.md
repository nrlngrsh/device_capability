# Contributing to Device Capability

Thanks for considering contributing! Here's how to get started.

## Getting Started

1. Fork and clone the repository
   ```bash
   git clone https://github.com/nrlngrsh/device_capability.git
   cd device_capability
   ```

2. Install dependencies
   ```bash
   flutter pub get
   cd example && flutter pub get
   ```

3. Make sure tests pass
   ```bash
   flutter test
   flutter analyze
   ```

## Development Guidelines

### Code Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format` before committing
- All public APIs must have documentation comments
- Keep functions focused and single-purpose

### Testing

- Write unit tests for all new features
- Maintain or improve existing test coverage
- Test edge cases and error conditions
- Run `flutter test` before submitting PRs

### Commit Messages

Use clear, descriptive commit messages:

```
feat: Add GPU performance estimation
fix: Correct thermal state detection on Android
docs: Update README with new configuration options
test: Add tests for memory tier calculation
refactor: Simplify scoring algorithm
```

Prefixes:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Test additions or modifications
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `chore`: Maintenance tasks

### Pull Requests

1. Create a feature branch from `main`
2. Make your changes with appropriate tests
3. Ensure all tests pass
4. Update documentation if needed
5. Submit a PR with a clear description

PR checklist:
- [ ] Code follows style guidelines
- [ ] Tests added/updated and passing
- [ ] Documentation updated
- [ ] CHANGELOG.md updated (if applicable)
- [ ] No analysis warnings

## Architecture Overview

### Project Structure

```
lib/
  ├── device_capability.dart          # Public API exports
  ├── src/
  │   ├── device_capability.dart      # Main singleton class
  │   ├── models/                     # Data models
  │   ├── engine/                     # Scoring and tier calculation
  │   ├── platform/                   # Platform channel interface
  │   └── helpers/                    # Helper extensions
android/                              # Android native implementation
ios/                                  # iOS native implementation
test/                                 # Unit tests
example/                              # Example application
```

### Adding New Metrics

To add a new device metric:

1. **Update native code** (Android and iOS)
   - Add metric collection in native plugins
   - Return data through method channel

2. **Update `RawDeviceInfo` model**
   - Add field for new metric
   - Update `fromMap` factory
   - Update `toMap` method

3. **Update scoring engine** (if affects performance)
   - Add calculation method in `PerformanceEngine`
   - Update weight in `DeviceCapabilityConfig`
   - Adjust overall score calculation

4. **Add tests**
   - Test metric collection
   - Test scoring impact
   - Test edge cases

5. **Update documentation**
   - Document new metric in README
   - Add examples if applicable
   - Update CHANGELOG

## Platform-Specific Development

### Android

- Location: `android/src/main/kotlin/com/nrlngrsh/device_capability/`
- Language: Kotlin
- Min SDK: 21

Key files:
- `DeviceCapabilityPlugin.kt`: Main plugin implementation

### iOS

- Location: `ios/Classes/`
- Language: Swift
- Min version: 12.0

Key files:
- `DeviceCapabilityPlugin.swift`: Main plugin implementation

## Testing on Real Devices

To test on physical devices:

```bash
cd example
flutter run --release
```

Test scenarios:
- Low-end device (2GB RAM, 2-4 cores)
- Mid-range device (4GB RAM, 4-6 cores)
- High-end device (6GB+ RAM, 8+ cores)
- Various thermal states
- Low power mode enabled/disabled
- Different storage conditions

## Debugging

Enable verbose logging:

```dart
// In example app
print(DeviceCapability.instance.rawInfo);
print('Score: ${DeviceCapability.instance.performanceScore}');
```

## Documentation

- Keep README.md up to date
- Document all public APIs with dartdoc comments
- Include code examples for new features
- Update CHANGELOG.md for all releases

## Release Process

1. Update version in `pubspec.yaml`
2. Update CHANGELOG.md with changes
3. Run full test suite
4. Create git tag: `git tag v0.x.0`
5. Push tag: `git push origin v0.x.0`
6. Publish to pub.dev: `flutter pub publish`

## Questions?

Feel free to open an issue for bugs, feature requests, or questions. Just check if someone else hasn't already reported the same thing.

---

Thank you for contributing!
