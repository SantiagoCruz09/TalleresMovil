import 'package:flutter/material.dart';
import 'custom_drawer.dart';

class BaseView extends StatelessWidget {
	final String title;
	final Widget? body;
	final Widget? floatingActionButton;

	const BaseView({
		Key? key,
		this.title = '',
		this.body,
		this.floatingActionButton,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text(title),
				centerTitle: true,
			),
			drawer: const CustomDrawer(),
			body: body ?? const SizedBox.shrink(),
			floatingActionButton: floatingActionButton,
		);
	}
}

