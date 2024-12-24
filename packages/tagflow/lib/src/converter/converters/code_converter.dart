import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';

/// A converter for code elements (`code` and `pre` tags)
final class CodeConverter extends ElementConverter {
  /// Create a new code converter
  const CodeConverter();

  @override
  Set<String> get supportedTags => {'code', 'pre'};

  @override
  Widget convert(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    // Handle pre tag (code block)
    if (element.tag == 'pre') {
      return _buildPreElement(element, context, converter);
    }

    // Handle inline code
    return _buildInlineCode(element, context, converter);
  }

  Widget _buildPreElement(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    final style = resolveStyle(element, context);

    // Pre elements typically contain a code element
    final codeElement = element.children.firstWhere(
      (e) => e.tag == 'code',
      orElse: () => element,
    );

    final children = converter.convertChildren(codeElement.children, context);

    return StyledContainer(
      style: style,
      tag: element.tag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildInlineCode(
    TagflowElement element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    final style = resolveStyle(element, context);

    final children = converter.convertChildren(element.children, context);

    // Handle single text child more efficiently
    if (children.length == 1 && children.first is Text) {
      final text = children.first as Text;
      return StyledContainer(
        style: style,
        tag: element.tag,
        child: Text(
          text.data ?? '',
          style: style.textStyle,
          textAlign: style.textAlign,
        ),
      );
    }

    // Handle multiple or non-text children
    return StyledContainer(
      style: style,
      tag: element.tag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
